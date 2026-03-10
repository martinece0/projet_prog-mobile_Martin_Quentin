/// <reference path="../pb_data/types.d.ts" />

// Configuration du Cron : */2 * * * * = Toutes les 2 minutes
cronAdd("sync_rappels", "0 8,20 * * *", () => {
    try {
        // 1. Récupération du JSON
        const url = "https://codelabs.formation-flutter.fr/assets/rappels.json"
        const res = $http.send({
            url: url,
            method: "GET",
            timeout: 30,
        })

        if (res.statusCode != 200) {
            console.log("Erreur lors de la récupération du JSON :", res.statusCode)
            return
        }

        const items = res.json
        const collection = $app.findCollectionByNameOrId("rappels")

        // 2. Traitement des données dans une transaction
        $app.runInTransaction((txApp) => {
            for (let item of items) {
                // On utilise numero_fiche comme identifiant unique pour éviter les doublons
                const uniqueId = item.numero_fiche
                if (!uniqueId) continue

                let record
                try {
                    // On vérifie si ce rappel existe déjà en base
                    record = txApp.findFirstRecordByData("rappels", "numero_fiche", uniqueId)
                } catch (e) {
                    record = null
                }

                // S'il n'existe pas, on crée un nouvel enregistrement
                if (!record) {
                    record = new Record(collection)
                }

                // --- MAPPING CRITIQUE POUR FLUTTER ---
                
                // IMPORTANT : Conversion du GTIN (nombre dans le JSON) en String pour le champ barcode
                if (item.gtin != null) {
                    // On transforme le nombre en texte et on nettoie les espaces
                    record.set("barcode", String(item.gtin).trim());
                }

                // Mapping des autres champs selon ta structure PocketBase
                record.set("nom_produit", item.libelle || item.modeles_ou_references || "Produit sans nom");
                record.set("numero_fiche", uniqueId);
                record.set("marque_produit", item.marque_produit);
                record.set("motif_rappel", item.motif_rappel);
                record.set("risques_encourus", item.risques_encourus);
                record.set("distributeurs", item.distributeurs);
                record.set("zone_geographique", item.zone_geographique_de_vente);
                record.set("lien_pdf", item.lien_vers_affichette_pdf);
                
                // On prépare le texte des dates pour l'affichage simple
                const dStart = item.date_debut_commercialisation || "?";
                const dEnd = item.date_date_fin_commercialisation || "en cours";
                record.set("dates_commercialisation", "Du " + dStart + " au " + dEnd);

                // Sauvegarde de l'enregistrement
                txApp.save(record);
            }
        })

        console.log("[CRON SUCCESS] " + new Date().toLocaleTimeString() + " : " + items.length + " rappels synchronisés.");
    } catch (err) {
        console.log("[CRON ERROR] :", err);
    }
})
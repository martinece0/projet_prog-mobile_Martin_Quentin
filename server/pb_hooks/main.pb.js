/// <reference path="../pb_data/types.d.ts" />

cronAdd("sync_rappels", "0 8,20 * * *", () => {
        try {
        const url = "https://codelabs.formation-flutter.fr/assets/rappels.json"
        const res = $http.send({
            url: url,
            method: "GET",
            timeout: 30,
        })

        if (res.statusCode != 200) {
            console.log("Error fetching data:", res.statusCode)
            return
        }

        const raw = res.json
        let items = Array.isArray(raw) ? raw : (raw.list || raw.results || [])
        
        const collection = $app.findCollectionByNameOrId("rappels")

        $app.runInTransaction((txApp) => {
            for (let item of items) {
                const uniqueId = item.identification_produits
                if (!uniqueId) continue

                let record
                try {
                    // On cherche si le produit existe déjà pour le mettre à jour
                    record = txApp.findFirstRecordByData("rappels", "identification_produits", uniqueId)
                } catch (e) {
                    record = null
                }

                // S'il n'existe pas, on en crée un nouveau
                if (!record) {
                    record = new Record(collection)
                }

                // --- Mapping des champs ---
                record.set("gtin", item.gtin ? String(item.gtin) : "")
                record.set("numero_fiche", item.numero_fiche)
                record.set("identification_produits", uniqueId)
                record.set("libelle", item.libelle)
                record.set("marque_produit", item.marque_produit)
                record.set("motif_rappel", item.motif_rappel)
                record.set("risques_encourus", item.risques_encourus)
                record.set("conduites_a_tenir_par_le_consommateur", item.conduites_a_tenir_par_le_consommateur)
                record.set("liens_vers_les_images", item.liens_vers_les_images)
                record.set("lien_vers_affichette_pdf", item.lien_vers_affichette_pdf)
                record.set("distributeurs", item.distributeurs)
                record.set("zone_geographique_de_vente", item.zone_geographique_de_vente)
                record.set("informations_complementaires", item.informations_complementaires)
                record.set("rappel_guid", item.rappel_guid)
                record.set("id_source", item.id)

                // Dates
                if (item.date_publication) record.set("date_publication", item.date_publication)
                if (item.date_debut_commercialisation) record.set("date_debut_commercialisation", item.date_debut_commercialisation + " 00:00:00.000Z")
                if (item.date_date_fin_commercialisation) record.set("date_date_fin_commercialisation", item.date_date_fin_commercialisation + " 00:00:00.000Z")

                txApp.save(record)
            }
        })
        console.log("Synchro terminée : Données mises à jour (" + items.length + " items traités)")
    } catch (err) {
        console.log("Cron error:", err)
    }
})
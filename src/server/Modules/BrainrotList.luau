local brainrots = {}
-- penil
brainrots.BrainrotsList = {
	-- Common – all settings from the last Common
	{ name = "Noobini Pizzanini", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 25, baseWeight = 0.52 },
	{ name = "Lirilì Larilà", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 250, baseWeight = 0.52 },
	{ name = "Tim Cheese", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 500, baseWeight = 0.52 },
	{ name = "Fluriflura", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 750, baseWeight = 0.52 },
	{ name = "Talpa Di Fero", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 1000, baseWeight = 0.52 },
	{ name = "Svinina Bombardino", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 1200, baseWeight = 0.52 },
	{ name = "Pipi_Kiwi", moveSpeed = 1.4, catchTime = 3.5, rarity = "Common", value = 1500, baseWeight = 0.52 },

	-- Rare – all settings from the last Rare
	{ name = "Trippi Troppi", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 2000, baseWeight = 1.12 },
	{ name = "Tung Tung Tung Sahur", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 3000, baseWeight = 1.12 },
	{ name = "Gangster Footera", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 4000, baseWeight = 1.12 },
	{ name = "Bandito_Bobritto", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 4500, baseWeight = 1.12 },
	{ name = "Boneca Ambalabu", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 5000, baseWeight = 1.12 },
	{ name = "Cacto Hipopotamo", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 6500, baseWeight = 1.12 },
	{ name = "Ta Ta Ta Ta Sahur", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 7500, baseWeight = 1.12 },
	{ name = "Tric_Trac_Baraboom", moveSpeed = 2.3, catchTime = 4.5, rarity = "Rare", value = 9000, baseWeight = 1.12 },

	-- Epic – all settings from the last Epic
	{ name = "Cappuccino Assassino", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 10000, baseWeight = 1.85 },
	{ name = "Brr Brr Patapim", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 15000, baseWeight = 1.85 },
	{ name = "Trulimero Trulicina", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 20000, baseWeight = 1.85 },
	{ name = "Bambini_Crostini", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 22500, baseWeight = 1.85 },
	{ name = "Bananita Dolphinita", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 25000, baseWeight = 1.85 },
	{ name = "Perochello_Lemonchello", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 27500, baseWeight = 1.85 },
	{ name = "Avocadini Guffo", moveSpeed = 3.4, catchTime = 5.5, rarity = "Epic", value = 35000, baseWeight = 1.85 },

	-- Legendary – all settings from the last Legendary
	{ name = "Burbaloni Loliloli", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 35000, baseWeight = 4.00 },
	{ name = "Chimpazini Bananini", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 50000, baseWeight = 4.00 },
	{ name = "Ballerina Cappuccina", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 100000, baseWeight = 4.00 },
	{ name = "Chef Crabracadabra", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 150000, baseWeight = 4.00 },
	{ name = "Lionel_Cactuseli", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 175000, baseWeight = 4.00 },
	{ name = "Glorbo Fruttodrillo", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 200000, baseWeight = 4.00 },
	{ name = "Blueberrinni_Octopusini", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 250000, baseWeight = 4.00 },
	{ name = "Strawberrelli Flamingelli", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 275000, baseWeight = 4.00 },
	{ name = "Pandaccini Bananini", moveSpeed = 4.7, catchTime = 6.5, rarity = "Legendary", value = 300000, baseWeight = 4.00 },

	-- Mythic – all settings from the last Mythic
	{ name = "Frigo Camelo", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 300000, baseWeight = 9.20 },
	{ name = "Orangutini Ananassini", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 400000, baseWeight = 9.20 },
	{ name = "Rhino Toasterino", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 450000, baseWeight = 9.20 },
	{ name = "Bombardiro Crocodilo", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 500000, baseWeight = 9.20 },
	{ name = "Bombombini Gusini", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 1000000, baseWeight = 9.20 },
	{ name = "Cavallo_Virtuoso", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 2500000, baseWeight = 9.20 },
	{ name = "Gorillo Watermelondrillo", moveSpeed = 5.6, catchTime = 7.5, rarity = "Mythic", value = 3000000, baseWeight = 9.20 },

	-- Brainrot God – all settings from the last Brainrot God
	{ name = "Cocofanto Elefanto", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 5000000, baseWeight = 16.60 },
	{ name = "Girafa_Celestre", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 7500000, baseWeight = 16.60 },
	{ name = "Gattatino_Nyanino", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 7500000, baseWeight = 16.60 },
	{ name = "Tralalero Tralala", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 10000000, baseWeight = 16.60 },
	{ name = "Espresso Signora", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 25000000, baseWeight = 16.60 },
	{ name = "Odin Din Din Dun", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 15000000, baseWeight = 16.60 },
	{ name = "Statutino Libertino", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 20000000, baseWeight = 16.60 },
	{ name = "Orcalero Orcala", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God (Lucky Box)", value = 15000000, baseWeight = 16.60 },
	{ name = "Trenostruzzo_Turbo_3000", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 25000000, baseWeight = 16.60 },
	{ name = "Ballerino Lololo", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 35000000, baseWeight = 16.60 },
	{ name = "Los Crocodillitos", moveSpeed = 7.5, catchTime = 8.5, rarity = "Brainrot God", value = 12500000, baseWeight = 16.60 },

	-- Secret – all settings from the last Secret
	{ name = "La_Vacca_Saturno_Saturnita", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 50000000, baseWeight = 46.00 },
	{ name = "Chimpanzini Spiderini", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 100000000, baseWeight = 46.00 },
	{ name = "Los Tralaleritos", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 150000000, baseWeight = 46.00 },
	{ name = "Las Tralaleritas", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 150000000, baseWeight = 46.00 },
	{ name = "Graipuss Medussi", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 250000000, baseWeight = 46.00 },
	{ name = "Las Vaquitas Saturnitas", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 160000000, baseWeight = 46.00 },
	{ name = "Chicleteira Bicicleteira", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 125000000, baseWeight = 46.00 },
	{ name = "La_Grande_Combinasion", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 1000000000, baseWeight = 46.00 },
	{ name = "Nuclearo Dinossauro", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 2500000000, baseWeight = 46.00 },
	{ name = "Garama_and_Madundung", moveSpeed = 9.5, catchTime = 9.5, rarity = "Secret", value = 10000000000, baseWeight = 46.00 },
}


return brainrots

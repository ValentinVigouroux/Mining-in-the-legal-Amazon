clear all    /* Efface toutes les données et les résultats en mémoire */
set more off
cd "C:/Users/valen/Documents/COURS BRESIL MAG2/Projet de recherche ARAUJO Mine et Crime" 
import excel "mines_2004_2022.xlsx", sheet("Surfaces") firstrow clear

// Traitement des valeurs manquantes (Remplacer les nd par des "")

ds, has(type string)  // ds = selectionne toutes les var,  has(type ) string = si il y a >1 valeur str. 
foreach var in `r(varlist)' {  // (Backticks Apostrophe)  `' = appel à une macro
// ici la macro r(varlist) qui est accessible après la commande ds , cette macro retourne le résultat de la liste appelée par ds. 
	replace `var' = "0" if `var' == "nd"  // appel de var, une macro acessible après la commande for each 
}
destring *, replace force  // * = all  

// calcul tx évolution minier 
gen t_rt_mine = (PL_rt_mines2022 - PL_rt_mines2004)*100/PL_rt_mines2004
replace t_rt_mine = 0 if missing(t_rt_mine) // cas où 2004 ou 2022 =0 => corrige erreur

gen t_ra_mine = (PL_ra_mines2022 - PL_ra_mines2004)*100/PL_ra_mines2004
replace t_ra_mine = 0 if missing(t_ra_mine) 

gen t_ri_mine = (PL_ri_mines2022 - PL_ri_mines2004)*100/PL_ri_mines2004
replace t_ri_mine = 0 if missing(t_ri_mine)

reshape long PL_ra_mines PL_ri_mines PL_rt_mines PL_PA_ra_mines PL_PA_ri_mines PL_PA_rt_mines PL_TI_ra_mines PL_TI_ri_mines PL_TI_rt_mines, i(GEOCODE) j(annee)

// sauvegarde des données pour l'étude géographique 
save "C:/Users/valen/Documents/COURS BRESIL MAG2/Projet de recherche ARAUJO Mine et Crime/Mines.dta", replace


//calcul mines légales 
gen ilt_mines = PL_PA_rt_mines + PL_TI_rt_mines
gen ilta_mines = PL_PA_ra_mines + PL_TI_ra_mines
gen ilti_mines = PL_PA_ri_mines + PL_TI_ri_mines

//calcul mines illégales 
gen Lt_mines = PL_rt_mines - ilt_mines 
gen Lta_mines = PL_ra_mines - ilta_mines 
gen Lti_mines = PL_ri_mines - ilti_mines 

collapse (sum) ilt_mines ilta_mines ilti_mines Lt_mines Lta_mines Lti_mines PL_ra_mines PL_ri_mines PL_rt_mines PL_PA_ra_mines PL_PA_ri_mines PL_PA_rt_mines PL_TI_ra_mines PL_TI_ri_mines PL_TI_rt_mines, by(annee)

//Graphique 1 : Evolution de la Surface totale des Mines d'or en Amazonie (décomposition légal /illégal )
twoway ///
	(area PL_rt_mines annee, color(blue)) ///
	(line PL_rt_mines annee, lcolor(blue)) ///
	(area ilt_mines annee, color(red)) ///
	(line ilt_mines annee, lcolor(red)), ///
	legend(label(1 "Mines Légales") label(2 "") label(3 "Mines Illégales") label(4 "") size(medium)) ///
	xlabel(2004(2)2022, labsize(medium)) ///
	xsize(6) ///
	xtitle("Année", size(medium)) ///
	ysize(6) ///
	ylabel(0(500)3000, labsize(medium)) ///
	ytitle("Surface totale (km²)" " ",linegap(7) size(medium)) ///
	title("{stSerif:Evolution de la Surface Totale des Mines d'or en Amazonie Légale}" " ", size(vlarge))
graph export "graph1.png", width(4000) height(2000) replace


//Graphique 2 : Evolution de la Surface des Mines d'or illégales en Amazonie 
twoway ///
	(area ilt_mines annee, color("153 101 21")) ///
	(line ilt_mines annee, lcolor("153 101 21")) ///
	(area ilti_mines annee, color("150 150 150")) ///
	(line ilti_mines annee, lcolor("150 150 150")), ///
	legend(label(1 "Mines artisanales") label(2 "      illégales") label(3 "Mines industrielles") label(4 "      illégales") size(medium)) ///
	xlabel(2004(2)2022, labsize(medium)) ///
	xsize(6) ///
	xtitle("Année", size(medium)) ///
	ysize(6) ///
	ylabel(0(200)1400, labsize(medium)) ///
	ytitle("Surface totale (km²)" " ",linegap(7) size(medium)) ///
	title("{stSerif: Surface des Mines d'or illégales en Amazonie légale par type d'exploitation}" " ", size(vlarge))
graph export "graph2.png", width(4000) height(2000) replace // ce qui compte c'est le rapport entre width et height par leur valeur 


//Graphique 3 : Evolution de la Surface des Mines d'or Légales en Amazonie 
twoway ///
	(area Lt_mines annee, color(orange)) ///
	(line Lt_mines annee, lcolor(orange)) ///
	(area Lti_mines annee, color("0 80 255")) ///
	(line Lti_mines annee, lcolor("0 80 255")), ///
	legend(label(1 "Mines artisanales") label(2 "      légales") label(3 "Mines industrielles") label(4 "      légales") size(medium)) ///
	xlabel(2004(2)2022, labsize(medium)) ///
	xsize(6) ///
	xtitle("Année" , size(medium)) ///	
	ysize(6) ///
	ylabel(0(200)1800, labsize(medium)) ///
	ytitle("Surface totale (km²)" " ", linegap(9) size(medium)) ///
	title("{stSerif: Surface des Mines d'or légales en Amazonie légale par type d'exploitation}" " ", size(vlarge))
graph export "graph3.png", width(4000) height(2000) replace

//Graphique 4 : Surface des Mines d'or illégales selon le type de zone 
twoway ///
	(area ilt_mines annee, color("84 190 83")) ///
	(line ilt_mines annee, lcolor("84 190 83")) ///
	(area PL_TI_rt_mines annee, color("203 0 203")) ///
	(line PL_TI_rt_mines annee, lcolor("203 0 203")), ///
	legend(label(1 "Zone Protégée") label(2 "") label(3 "Terre Indigène") label(4 "") size(medium)) ///
	xlabel(2004(2)2022, labsize(medium)) ///
	xsize(6) ///
	xtitle("Année", size(medium)) ///
	ysize(6) ///
	ylabel(0(200)1400, labsize(medium)) ///
	ytitle("Surface totale (km²)" " ",linegap(2) size(medium)) ///
	title("{stSerif: Surface des Mines d'or illégales selon le type de zone}" " " " ", size(vlarge))
graph export "graph4.png", width(4000) height(2000) replace



//////////         Analyse régionale de la variation minière          ///////////

//ssc install spmap, replace      à executer si pas déjà installé 
//ssc install geodist, replace

//  ssc install shp2dta, replace  si pas encore installé


// Import des tracé des Municipalités 
shp2dta using "C:/Users/valen/Documents/COURS BRESIL MAG2/Projet de recherche ARAUJO Mine et Crime/BR_Municipios_2022", ///
	database("municipios_data.dta") ///
	coordinates("municipios_coords.dta") ///
	genid(id) ///
	replace
	
// ajouter le contour des UF 
shp2dta using "C:/Users/valen/Documents/COURS BRESIL MAG2/Projet de recherche ARAUJO Mine et Crime/BR_UF_2022", ///
	database("regions_data.dta") ///
	coordinates("regions_coords.dta") ///
	genid(region_id) ///
	replace	

use regions_coords.dta, clear 
drop if inrange(_ID, 7, 22)
drop if _ID == 24
drop if _ID == 25
save regions_coords.dta, replace

use municipios_data.dta, clear
rename CD_MUN GEOCODE
rename id _ID
save municipios_data.dta, replace

use "C:/Users/valen/Documents/COURS BRESIL MAG2/Projet de recherche ARAUJO Mine et Crime/Mines.dta", clear
keep if annee == 2022 // pour avoir une donnée par municipalité et pas plusieurs 
tostring GEOCODE, replace // convertir la variable Geocode en chaine de charactère pour effectuer le merge (l'id doit avoir le même type dans les 2 fichiers)
merge 1:1 GEOCODE using municipios_data.dta
keep if annee == 2022 // supprimmer les municipalités pour lesquelles ont a pas de données 

// Carte 1 : Evolution de la surface minière TOTALE
spmap t_rt_mine using municipios_coords.dta, id(_ID) ///
	clmethod(custom) ///
	clbreaks(-20 -10 -1 1 10 50 100 200 300 1000000) ///
	fcolor("255 49 254" "255 168 254" "207 245 227" "175 210 255" "123 165 255" "66 97 255" "0 22 235" "0 22 128" "0 22 58") /// 
	legend(label(2 "Diminution >10%") label(3 "Diminution <10%") label(4 "Pas de changement" ) label(5 "Croissance <10%") label(6 "+10-50%") label(7 "+50%-100%") label(8 "+100-200%") label(9 "+200-300%") label(10 "+>300%")) ///
	legtitle("Evolution de la Surface") ///
	ocolor(Greys) ///
	polygon(data(regions_coords.dta) ocolor(black) osize(thin))	///
	title("{stSerif:Evolution de la surface minière Totale}")
graph export "t_rt_map.png", width(2000) replace


// Carte 2 : Evolution de la surface minière ARTISANALE 
spmap t_ra_mine using municipios_coords.dta, id(_ID) ///
	clmethod(custom) ///
	clbreaks(-20 -10 -1 1 10 50 100 200 300 1000000) ///
	fcolor("184 141 252" "215 164 252" "255 178 178" "255 113 113" "255 63 63" "230 0 0" "195 0 0" "155 0 0" "114 0 0") /// 
	legend(label(2 "Diminution >10%") label(3 "Diminution <10%") label(4 "Pas de changement" ) label(5 "Croissance <10%") label(6 "+10-50%") label(7 "+50%-100%") label(8 "+100-200%") label(9 "+200-300%") label(10 "+>300%")) ///
	legtitle("Evolution de la Surface") ///
	ocolor(Greys) ///
	polygon(data(regions_coords.dta) ocolor(black) osize(thin))	///
	title("{stSerif:Evolution de la surface minière Artisanale}")
graph export "t_ra_map.png", width(2000) replace

// Carte 3 : Evolution de la surface minière INDUSTRIELLE
spmap t_ri_mine using municipios_coords.dta, id(_ID) ///
	clmethod(custom) ///
	clbreaks(-20 -10 -1 1 10 50 100 200 300 1000000) ///
	fcolor("206 151 206" "234 197 173" "247 247 247" "255 255 0" "255 219 0" "255 170 0" "233 147 0" "190 114 0" "146 72 0") /// 
	legend(label(2 "Diminution 10-20%") label(3 "Diminution <10%") label(4 "Pas de changement%" ) label(5 "Croissance <10%") label(6 "+10-50%") label(7 "+50%-100%") label(8 "+100-200%") label(9 "+200-300%") label(10 "+>300%")) ///
	legtitle("Evolution de la Surface") ///
	ocolor(Greys) ///
	polygon(data(regions_coords.dta) ocolor(black) osize(thin)) ///
	title("{stSerif:Evolution de la surface minière Industrielle}")
graph export "t_ri_map.png", width(2000) replace
/*
// Carte 4 : Evolution de la surface minière ILLEGALE
spmap t_ri_mine using municipios_coords.dta, id(_ID) ///
	clmethod(custom) ///
	clbreaks(-20 -10 -1 1 10 50 100 200 300 1000000) ///
	fcolor("206 151 206" "234 197 173" "247 247 247" "255 255 0" "255 219 0" "255 170 0" "233 147 0" "190 114 0" "146 72 0") /// 
	legend(label(2 "Diminution 10-20%") label(3 "Diminution <10%") label(4 "Pas de changement%" ) label(5 "Croissance <10%") label(6 "+10-50%") label(7 "+50%-100%") label(8 "+100-200%") label(9 "+200-300%") label(10 "+>300%")) ///
	legtitle("Evolution de la Surface") ///
	ocolor(Greys) ///
	polygon(data(regions_coords.dta) ocolor(black) osize(thin))	
graph export "t_ri_map.png", width(2000) replace
*/

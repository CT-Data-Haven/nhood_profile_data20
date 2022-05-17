YR := 2020
RUN_R = Rscript $<
MAN_TXT := _utils/manual/sources.txt _utils/manual/urls.txt
HEADINGS := _utils/acs_indicator_headings.txt _utils/cdc_indicators.txt
INPUTS := input_data/acs_nhoods_by_city_$(YR).rds input_data/cdc_health_all_lvls_nhood_$(YR).rds 
OUTPUTS := output_data/all_nhood_$(YR)_acs_health_comb.rds

.PHONY: all 
all: viz distro 

.PHONY: viz
viz: to_viz/notes.json to_viz/indicators.json to_viz/nhood_wide_$(YR).json to_viz/cities/%.json

$(INPUTS): scripts/00a_download_data.R
	$(RUN_R)

to_viz/indicators.json: scripts/00b_make_headings.R 
	$(RUN_R)	

to_viz/notes.json: scripts/00c_make_geo_notes.R $(MAN_TXT) $(INPUTS)
	$(RUN_R)

$(OUTPUTS): scripts/01_join_acs_health.R $(INPUTS) _utils/city_geos.rds
	$(RUN_R)

to_viz/nhood_wide_$(YR).json: scripts/03_prep_json_to_viz.R $(OUTPUTS)
	$(RUN_R)

to_viz/cities/%.json: scripts/04_make_shapefiles.R 
	$(RUN_R)

.PHONY: distro 
distro: to_distro/%.csv # add urls.txt

to_distro/%.csv: scripts/02_prep_distro.R to_viz/indicators.json $(OUTPUTS)
	$(RUN_R)

scripts/*.R: _utils/pkgs.R

.PHONY: clean
clean:
	rm -f to_distro/* to_viz/*.json to_viz/cities/* input_data/* output_data/* _utils/*.txt
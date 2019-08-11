WIKI_TEMP_DIR = $(TEMP_DIR)/wiktionary
WIKI_PART_DIR = $(PART_DIR)/wiktionary

WIKI_LANGS = \
			 bg ca cs da de el en eo es et eu fi fr gl he hr hu id io is it ka \
			 ku la li lt mg nl no oc pl pt ro ru sk sl so sr sv sw tr uk vi zh \
			 ar az fa hi ja ko mk ms th

WIKI_TRIANGLES = \
			  ar_en_ku \
			  en_no_sv \

wiki_lang = $(firstword $(subst ., ,$(notdir $1)))
wiki_triangle_langs = $(subst _, ,$(patsubst $(WIKI_TEMP_DIR)/%.3,%,$1))

WIKI_TXT = $(patsubst %,$(WIKI_TEMP_DIR)/%.txt,$(WIKI_LANGS))
WIKI_BZ2 = $(WIKI_TXT:.txt=.xml.bz2)
WIKI_2 = $(WIKI_TXT:.txt=.2)
WIKI_3 = $(patsubst %,$(WIKI_TEMP_DIR)/%.3,$(WIKI_TRIANGLES))

download: $(WIKI_BZ2)
extract: $(WIKI_2) $(WIKI_3)
convert: wiktionary


wiktionary: $(WIKI_2) $(WIKI_3)
	@mkdir -p $(WIKI_PART_DIR)
	$(SCRIPTS_DIR)/wiki_convert.py $(WIKI_TEMP_DIR) $(WIKI_PART_DIR) $(DICT_VERSION)

$(WIKI_BZ2): %.xml.bz2:
	$(eval lang := $(call wiki_lang,$@))
	@mkdir -p $(WIKI_TEMP_DIR)
	wget -nv -O $@ http://dumps.wikimedia.org/$(lang)wiktionary/latest/$(lang)wiktionary-latest-pages-meta-current.xml.bz2

$(WIKI_TXT): %.txt: %.xml.bz2
	bzcat $< | $(SCRIPTS_DIR)/wiki_articles.py > $@

$(WIKI_2): %.2: %.txt
	$(SCRIPTS_DIR)/wiki_extract.py $(call wiki_lang,$@) $< $@

$(WIKI_3): %.3: $(WIKI_2)
	$(SCRIPTS_DIR)/wiki_triangulate.py $(WIKI_TEMP_DIR) $(WIKI_TEMP_DIR) $(call wiki_triangle_langs,$@)

.PHONY: wiktionary

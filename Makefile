DOCSET_NAME = GNU_Make

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

MANUAL_URL  = http://www.gnu.org/software/make/manual/make.html_node.tar.gz
MANUAL_FILE = tmp/make.html_node.tar.gz

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE) $(ICON_FILE)

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index.rb $(DOCUMENTS_DIR)
	rm -f $@
	ruby src/index.rb $(DOCUMENTS_DIR)/*.html | sqlite3 $@

$(ICON_FILE): src/icon.png $(DOCSET_DIR)
	cp src/icon.png $@

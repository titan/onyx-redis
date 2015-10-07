MAINCLASS:=onyx.plugin.redis
TESTCLASS:=test
NAME = onyx-redis
SOURCE = $(NAME).org
DOCTARGET = $(NAME).pdf
VERSION = 0.7.0

EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)

BUILDDIR=/dev/shm/${NAME}-build
SRCDIR=$(BUILDDIR)/src
TESTDIR=$(BUILDDIR)/test
CLASSDIR=$(BUILDDIR)/classes
CORESRC=$(SRCDIR)/onyx/plugin/redis.clj
COREOBJ=$(CLASSDIR)/onyx/plugin/redis__init.class
TESTSRC=$(TESTDIR)/test.clj
TESTOBJ=$(CLASSDIR)/test.class
TARGET:=$(BUILDDIR)/$(NAME)-$(VERSION).jar

CLASSPATHCONFIG:=classpath

ifeq ($(CLASSPATHCONFIG), $(wildcard $(CLASSPATHCONFIG)))
CLASSPATH:=$(shell cat $(CLASSPATHCONFIG))
endif

PNGS=$(patsubst %.aa,%.png,$(shell find . -name "*.aa"))
PNGS+=$(patsubst %.uml,%.png,$(shell find . -name "*.uml"))

vpath %.clj $(SRCDIR)
vpath %.java $(SRCDIR)
vpath %.class $(CLASSDIR)

all: $(COREOBJ)

doc: $(DOCTARGET)

jar: $(TARGET)

test: $(COREOBJ) $(TESTOBJ)

$(DOCTARGET): $(SOURCE) style.sty $(PNGS)
	pandoc -H $(HOME)/templates/style.sty --latex-engine=xelatex --template=$(HOME)/templates/pandoc-template.tex -f org -o $@ $(SOURCE)

$(TARGET): $(COREOBJ)
	jar cvf $(TARGET) `find $(CLASSDIR)/onyx/plugin -type f | sed "s#$(CLASSDIR)# -C $(CLASSDIR) \.#g" | xargs`

$(SOURCE): preface.org code.org test.org
	@cat preface.org > $(SOURCE)
	@cat code.org >> $(SOURCE)
	@cat test.org >> $(SOURCE)

$(CORESRC): code.org | prebuild
	emacs $< --batch -f org-babel-tangle --kill

$(COREOBJ): $(CORESRC)
	java -cp $(CLASSPATH):$(SRCDIR) -Dclojure.compile.path=$(CLASSDIR) clojure.lang.Compile $(MAINCLASS)

$(TESTSRC): test.org | prebuild
	emacs $< --batch -f org-babel-tangle --kill

$(TESTOBJ): $(TESTSRC)
	java -cp $(CLASSPATH):$(TESTDIR) -Dclojure.compile.path=$(CLASSDIR) clojure.lang.Compile $(TESTCLASS)

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
	@mkdir -p $(CLASSDIR)
endif

%.png: %.uml
	java -jar /opt/plantuml.jar -tpng -nbthread auto $<

%.png: %.aa
	java -jar /opt/ditaa0_9.jar -e utf-8 -s 2.5 $< $@

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean doc jar test prebuild

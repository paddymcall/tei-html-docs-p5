;; tei-html-docs-p5.el -- Show TEI guidelines for current element
;;
;; Copyright (C) 2015-2019 Patrick McAllister
;;
;; Author: Patrick McAllister <pma@rdorte.org>
;; URL: https://github.com/paddymcall/tei-html-docs-p5
;; Version: 1.1
;;
;;
;;
;; Copyright (C) 2005 P J Heslin
;;
;; Author: Peter Heslin <p.j.heslin@dur.ac.uk>
;; URL: http://www.dur.ac.uk/p.j.heslin/Software/Emacs
;; Version: 1.0
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; If you do not have a copy of the GNU General Public License, you
;; can obtain one by writing to the Free Software Foundation, Inc., 59
;; Temple Place - Suite 330, Boston, MA 02111-1307, USA.

;;; Commentary:
;;
;; Short version:
;;
;; - M-x tei-html-docs-p5-element (from within a TEI XML document)
;;
;; to customize:
;;
;; - M-x customize-apropos tei-html-docs-p5
;;
;; Details:
;;
;; A quick but useful hack for TEI-P5 XML documents: it provides a
;; function that looks up the name of the element before point and
;; displays the TEI guidelines for that element.
;;
;; You need to download and unzip the HTML documentation from
;; http://tei.sf.net (or, nowadays, github) -- the filename will look something like
;; tei-p5-doc-0.1.9.zip
;;
;; Now set the variable tei-html-docs-p5-dir to the directory with all
;; of the ref-*.html files you just unzipped:
;;
;; M-x customize-variable RET tei-html-docs-p5-dir
;;
;; If you don't set tei-html-docs-p5-dir, then the on-line version of the
;; docs on the TEI web-site will be used instead.
;;
;; You can configure the browser to use with M-x customize-variable
;; RET tei-html-docs-p5-view-command
;;
;; Then put this package somewhere in your load-path, require it, and
;; assign the function tei-html-docs-p5-element-at-point to a
;; key-binding, with lines like these in your .emacs (this example
;; assumes you use nxml-mode to edit TEI documents):
;;
;;    (require 'tei-html-docs-p5)
;;    (define-key nxml-mode-map (kbd "<M-f11>") 'tei-html-docs-p5-element)

;;; Code:

(require 'xmltok)

(defcustom tei-html-docs-p5-dir nil
  "Directory containing the TEI P5 documentation in HTML format.

  If nil, use the on-line version."
  :type '(choice directory (const :tag "Use online version" nil))
  :group 'tei-html-docs-p5)

(defcustom tei-html-docs-p5-url "https://www.tei-c.org/release/doc/tei-p5-doc/en/html/"
  "Base URL for viewing the TEI P5 Documentation."
  :type 'string
  :group 'tei-html-docs-p5)

(defcustom tei-html-docs-p5-view-command 'eww-browse-url
  "Command to use to view the TEI documentation."
  ;; :type '(function :tag "Select how to browse the TEI docs.")
  :type '(choice (function-item :tag "eww" eww)
		 (function-item :tag "w3m" w3m-browse-url)
		 (function-item :tag "default browser" browse-url))
  :group 'tei-html-docs-p5)

(setq tei-html-docs-p5-view-command 'browse-url)

;; Almost all, but unfortunately not quite all of the files are of the
;; form ref-element.html.  For some reason, some element names have
;; been munged slightly.  So instead of doing (concat "ref-" (upcase
;; (match-string 1)) ".html") we have to supply this messy list.  It
;; was generated with this command line:
;;
;; grep h1 ref-* | perl -ne 'print "(\"", m/&lt;(.*?)&gt;/, "\" \"", m/(ref-.*?html)/, "\")\n"'  | grep -v '^(""'
;;
;; UPDATE: you should be able to get this list from `tei-html-docs-p5-make-elements-list'.

(defvar tei-html-docs-p5-element-alist nil
  "Maps TEI element names to the corresponding doc file.

To generate an up-to-date version for your documentation, set
this to the result of `tei-html-docs-p5-make-elements-list'.")

(setq tei-html-docs-p5-element-alist
      ;;  (pp (tei-html-docs-p5-make-elements-list))
  '(("TEI" "ref-TEI.html")
    ("ab" "ref-ab.html")
    ("abbr" "ref-abbr.html")
    ("abstract" "ref-abstract.html")
    ("accMat" "ref-accMat.html")
    ("acquisition" "ref-acquisition.html")
    ("activity" "ref-activity.html")
    ("actor" "ref-actor.html")
    ("add" "ref-add.html")
    ("addName" "ref-addName.html")
    ("addSpan" "ref-addSpan.html")
    ("additional" "ref-additional.html")
    ("additions" "ref-additions.html")
    ("addrLine" "ref-addrLine.html")
    ("address" "ref-address.html")
    ("adminInfo" "ref-adminInfo.html")
    ("affiliation" "ref-affiliation.html")
    ("age" "ref-age.html")
    ("alt" "ref-alt.html")
    ("altGrp" "ref-altGrp.html")
    ("altIdent" "ref-altIdent.html")
    ("altIdentifier" "ref-altIdentifier.html")
    ("alternate" "ref-alternate.html")
    ("am" "ref-am.html")
    ("analytic" "ref-analytic.html")
    ("anchor" "ref-anchor.html")
    ("app" "ref-app.html")
    ("appInfo" "ref-appInfo.html")
    ("application" "ref-application.html")
    ("arc" "ref-arc.html")
    ("argument" "ref-argument.html")
    ("att.ascribed" "ref-att.ascribed.html")
    ("att.breaking" "ref-att.breaking.html")
    ("att.cReferencing" "ref-att.cReferencing.html")
    ("att.canonical" "ref-att.canonical.html")
    ("att.citing" "ref-att.citing.html")
    ("att.combinable" "ref-att.combinable.html")
    ("att.coordinated" "ref-att.coordinated.html")
    ("att.damaged" "ref-att.damaged.html")
    ("att.datable.custom" "ref-att.datable.custom.html")
    ("att.datable" "ref-att.datable.html")
    ("att.datable.iso" "ref-att.datable.iso.html")
    ("att.datable.w3c" "ref-att.datable.w3c.html")
    ("att.datcat" "ref-att.datcat.html")
    ("att.declarable" "ref-att.declarable.html")
    ("att.declaring" "ref-att.declaring.html")
    ("att.deprecated" "ref-att.deprecated.html")
    ("att.dimensions" "ref-att.dimensions.html")
    ("att.divLike" "ref-att.divLike.html")
    ("att.docStatus" "ref-att.docStatus.html")
    ("att.duration" "ref-att.duration.html")
    ("att.duration.iso" "ref-att.duration.iso.html")
    ("att.duration.w3c" "ref-att.duration.w3c.html")
    ("att.editLike" "ref-att.editLike.html")
    ("att.edition" "ref-att.edition.html")
    ("att.enjamb" "ref-att.enjamb.html")
    ("att.entryLike" "ref-att.entryLike.html")
    ("att.fragmentable" "ref-att.fragmentable.html")
    ("att.global.analytic" "ref-att.global.analytic.html")
    ("att.global.change" "ref-att.global.change.html")
    ("att.global.facs" "ref-att.global.facs.html")
    ("att.global" "ref-att.global.html")
    ("att.global.linking" "ref-att.global.linking.html")
    ("att.global.rendition" "ref-att.global.rendition.html")
    ("att.global.responsibility" "ref-att.global.responsibility.html")
    ("att.handFeatures" "ref-att.handFeatures.html")
    ("att" "ref-att.html")
    ("att.identified" "ref-att.identified.html")
    ("att.internetMedia" "ref-att.internetMedia.html")
    ("att.interpLike" "ref-att.interpLike.html")
    ("att.lexicographic" "ref-att.lexicographic.html")
    ("att.measurement" "ref-att.measurement.html")
    ("att.media" "ref-att.media.html")
    ("att.metrical" "ref-att.metrical.html")
    ("att.milestoneUnit" "ref-att.milestoneUnit.html")
    ("att.msExcerpt" "ref-att.msExcerpt.html")
    ("att.namespaceable" "ref-att.namespaceable.html")
    ("att.naming" "ref-att.naming.html")
    ("att.patternReplacement" "ref-att.patternReplacement.html")
    ("att.personal" "ref-att.personal.html")
    ("att.placement" "ref-att.placement.html")
    ("att.pointing.group" "ref-att.pointing.group.html")
    ("att.pointing" "ref-att.pointing.html")
    ("att.ranging" "ref-att.ranging.html")
    ("att.rdgPart" "ref-att.rdgPart.html")
    ("att.readFrom" "ref-att.readFrom.html")
    ("att.repeatable" "ref-att.repeatable.html")
    ("att.resourced" "ref-att.resourced.html")
    ("att.scoping" "ref-att.scoping.html")
    ("att.segLike" "ref-att.segLike.html")
    ("att.sortable" "ref-att.sortable.html")
    ("att.source" "ref-att.source.html")
    ("att.spanning" "ref-att.spanning.html")
    ("att.styleDef" "ref-att.styleDef.html")
    ("att.tableDecoration" "ref-att.tableDecoration.html")
    ("att.textCritical" "ref-att.textCritical.html")
    ("att.timed" "ref-att.timed.html")
    ("att.transcriptional" "ref-att.transcriptional.html")
    ("att.translatable" "ref-att.translatable.html")
    ("att.typed" "ref-att.typed.html")
    ("att.witnessed" "ref-att.witnessed.html")
    ("attDef" "ref-attDef.html")
    ("attList" "ref-attList.html")
    ("attRef" "ref-attRef.html")
    ("author" "ref-author.html")
    ("authority" "ref-authority.html")
    ("availability" "ref-availability.html")
    ("back" "ref-back.html")
    ("bibl" "ref-bibl.html")
    ("biblFull" "ref-biblFull.html")
    ("biblScope" "ref-biblScope.html")
    ("biblStruct" "ref-biblStruct.html")
    ("bicond" "ref-bicond.html")
    ("binary" "ref-binary.html")
    ("binaryObject" "ref-binaryObject.html")
    ("binding" "ref-binding.html")
    ("bindingDesc" "ref-bindingDesc.html")
    ("birth" "ref-birth.html")
    ("bloc" "ref-bloc.html")
    ("body" "ref-body.html")
    ("broadcast" "ref-broadcast.html")
    ("byline" "ref-byline.html")
    ("c" "ref-c.html")
    ("cRefPattern" "ref-cRefPattern.html")
    ("caesura" "ref-caesura.html")
    ("calendar" "ref-calendar.html")
    ("calendarDesc" "ref-calendarDesc.html")
    ("camera" "ref-camera.html")
    ("caption" "ref-caption.html")
    ("case" "ref-case.html")
    ("castGroup" "ref-castGroup.html")
    ("castItem" "ref-castItem.html")
    ("castList" "ref-castList.html")
    ("catDesc" "ref-catDesc.html")
    ("catRef" "ref-catRef.html")
    ("catchwords" "ref-catchwords.html")
    ("category" "ref-category.html")
    ("cb" "ref-cb.html")
    ("cell" "ref-cell.html")
    ("certainty" "ref-certainty.html")
    ("change" "ref-change.html")
    ("channel" "ref-channel.html")
    ("char" "ref-char.html")
    ("charDecl" "ref-charDecl.html")
    ("charName" "ref-charName.html")
    ("charProp" "ref-charProp.html")
    ("choice" "ref-choice.html")
    ("cit" "ref-cit.html")
    ("citedRange" "ref-citedRange.html")
    ("cl" "ref-cl.html")
    ("classCode" "ref-classCode.html")
    ("classDecl" "ref-classDecl.html")
    ("classRef" "ref-classRef.html")
    ("classSpec" "ref-classSpec.html")
    ("classes" "ref-classes.html")
    ("climate" "ref-climate.html")
    ("closer" "ref-closer.html")
    ("code" "ref-code.html")
    ("collation" "ref-collation.html")
    ("collection" "ref-collection.html")
    ("colloc" "ref-colloc.html")
    ("colophon" "ref-colophon.html")
    ("cond" "ref-cond.html")
    ("condition" "ref-condition.html")
    ("constitution" "ref-constitution.html")
    ("constraint" "ref-constraint.html")
    ("constraintSpec" "ref-constraintSpec.html")
    ("content" "ref-content.html")
    ("corr" "ref-corr.html")
    ("correction" "ref-correction.html")
    ("correspAction" "ref-correspAction.html")
    ("correspContext" "ref-correspContext.html")
    ("correspDesc" "ref-correspDesc.html")
    ("country" "ref-country.html")
    ("creation" "ref-creation.html")
    ("custEvent" "ref-custEvent.html")
    ("custodialHist" "ref-custodialHist.html")
    ("damage" "ref-damage.html")
    ("damageSpan" "ref-damageSpan.html")
    ("data.certainty" "ref-data.certainty.html")
    ("data.count" "ref-data.count.html")
    ("data.duration.iso" "ref-data.duration.iso.html")
    ("data.duration.w3c" "ref-data.duration.w3c.html")
    ("data.enumerated" "ref-data.enumerated.html")
    ("data.interval" "ref-data.interval.html")
    ("data.language" "ref-data.language.html")
    ("data.name" "ref-data.name.html")
    ("data.namespace" "ref-data.namespace.html")
    ("data.numeric" "ref-data.numeric.html")
    ("data.outputMeasurement" "ref-data.outputMeasurement.html")
    ("data.pattern" "ref-data.pattern.html")
    ("data.percentage" "ref-data.percentage.html")
    ("data.point" "ref-data.point.html")
    ("data.pointer" "ref-data.pointer.html")
    ("data.probability" "ref-data.probability.html")
    ("data.replacement" "ref-data.replacement.html")
    ("data.sex" "ref-data.sex.html")
    ("data.temporal.iso" "ref-data.temporal.iso.html")
    ("data.temporal.w3c" "ref-data.temporal.w3c.html")
    ("data.text" "ref-data.text.html")
    ("data.truthValue" "ref-data.truthValue.html")
    ("data.version" "ref-data.version.html")
    ("data.versionNumber" "ref-data.versionNumber.html")
    ("data.word" "ref-data.word.html")
    ("data.xTruthValue" "ref-data.xTruthValue.html")
    ("data.xmlName" "ref-data.xmlName.html")
    ("data.xpath" "ref-data.xpath.html")
    ("datatype" "ref-datatype.html")
    ("date" "ref-date.html")
    ("dateline" "ref-dateline.html")
    ("death" "ref-death.html")
    ("decoDesc" "ref-decoDesc.html")
    ("decoNote" "ref-decoNote.html")
    ("def" "ref-def.html")
    ("default" "ref-default.html")
    ("defaultVal" "ref-defaultVal.html")
    ("del" "ref-del.html")
    ("delSpan" "ref-delSpan.html")
    ("depth" "ref-depth.html")
    ("derivation" "ref-derivation.html")
    ("desc" "ref-desc.html")
    ("dictScrap" "ref-dictScrap.html")
    ("dim" "ref-dim.html")
    ("dimensions" "ref-dimensions.html")
    ("distinct" "ref-distinct.html")
    ("distributor" "ref-distributor.html")
    ("district" "ref-district.html")
    ("div" "ref-div.html")
    ("div1" "ref-div1.html")
    ("div2" "ref-div2.html")
    ("div3" "ref-div3.html")
    ("div4" "ref-div4.html")
    ("div5" "ref-div5.html")
    ("div6" "ref-div6.html")
    ("div7" "ref-div7.html")
    ("divGen" "ref-divGen.html")
    ("docAuthor" "ref-docAuthor.html")
    ("docDate" "ref-docDate.html")
    ("docEdition" "ref-docEdition.html")
    ("docImprint" "ref-docImprint.html")
    ("docTitle" "ref-docTitle.html")
    ("domain" "ref-domain.html")
    ("eLeaf" "ref-eLeaf.html")
    ("eTree" "ref-eTree.html")
    ("edition" "ref-edition.html")
    ("editionStmt" "ref-editionStmt.html")
    ("editor" "ref-editor.html")
    ("editorialDecl" "ref-editorialDecl.html")
    ("education" "ref-education.html")
    ("eg" "ref-eg.html")
    ("egXML" "ref-egXML.html")
    ("elementRef" "ref-elementRef.html")
    ("elementSpec" "ref-elementSpec.html")
    ("email" "ref-email.html")
    ("emph" "ref-emph.html")
    ("encodingDesc" "ref-encodingDesc.html")
    ("entry" "ref-entry.html")
    ("entryFree" "ref-entryFree.html")
    ("epigraph" "ref-epigraph.html")
    ("epilogue" "ref-epilogue.html")
    ("equipment" "ref-equipment.html")
    ("equiv" "ref-equiv.html")
    ("etym" "ref-etym.html")
    ("event" "ref-event.html")
    ("ex" "ref-ex.html")
    ("exemplum" "ref-exemplum.html")
    ("expan" "ref-expan.html")
    ("explicit" "ref-explicit.html")
    ("extent" "ref-extent.html")
    ("f" "ref-f.html")
    ("fDecl" "ref-fDecl.html")
    ("fDescr" "ref-fDescr.html")
    ("fLib" "ref-fLib.html")
    ("facsimile" "ref-facsimile.html")
    ("factuality" "ref-factuality.html")
    ("faith" "ref-faith.html")
    ("figDesc" "ref-figDesc.html")
    ("figure" "ref-figure.html")
    ("fileDesc" "ref-fileDesc.html")
    ("filiation" "ref-filiation.html")
    ("finalRubric" "ref-finalRubric.html")
    ("floatingText" "ref-floatingText.html")
    ("floruit" "ref-floruit.html")
    ("foliation" "ref-foliation.html")
    ("foreign" "ref-foreign.html")
    ("forename" "ref-forename.html")
    ("forest" "ref-forest.html")
    ("form" "ref-form.html")
    ("formula" "ref-formula.html")
    ("front" "ref-front.html")
    ("fs" "ref-fs.html")
    ("fsConstraints" "ref-fsConstraints.html")
    ("fsDecl" "ref-fsDecl.html")
    ("fsDescr" "ref-fsDescr.html")
    ("fsdDecl" "ref-fsdDecl.html")
    ("fsdLink" "ref-fsdLink.html")
    ("funder" "ref-funder.html")
    ("fvLib" "ref-fvLib.html")
    ("fw" "ref-fw.html")
    ("g" "ref-g.html")
    ("gap" "ref-gap.html")
    ("gb" "ref-gb.html")
    ("gen" "ref-gen.html")
    ("genName" "ref-genName.html")
    ("geo" "ref-geo.html")
    ("geoDecl" "ref-geoDecl.html")
    ("geogFeat" "ref-geogFeat.html")
    ("geogName" "ref-geogName.html")
    ("gi" "ref-gi.html")
    ("gloss" "ref-gloss.html")
    ("glyph" "ref-glyph.html")
    ("glyphName" "ref-glyphName.html")
    ("gram" "ref-gram.html")
    ("gramGrp" "ref-gramGrp.html")
    ("graph" "ref-graph.html")
    ("graphic" "ref-graphic.html")
    ("group" "ref-group.html")
    ("handDesc" "ref-handDesc.html")
    ("handNote" "ref-handNote.html")
    ("handNotes" "ref-handNotes.html")
    ("handShift" "ref-handShift.html")
    ("head" "ref-head.html")
    ("headItem" "ref-headItem.html")
    ("headLabel" "ref-headLabel.html")
    ("height" "ref-height.html")
    ("heraldry" "ref-heraldry.html")
    ("hi" "ref-hi.html")
    ("history" "ref-history.html")
    ("hom" "ref-hom.html")
    ("hyph" "ref-hyph.html")
    ("hyphenation" "ref-hyphenation.html")
    ("iNode" "ref-iNode.html")
    ("iType" "ref-iType.html")
    ("ident" "ref-ident.html")
    ("idno" "ref-idno.html")
    ("if" "ref-if.html")
    ("iff" "ref-iff.html")
    ("imprimatur" "ref-imprimatur.html")
    ("imprint" "ref-imprint.html")
    ("incident" "ref-incident.html")
    ("incipit" "ref-incipit.html")
    ("index" "ref-index.html")
    ("institution" "ref-institution.html")
    ("interaction" "ref-interaction.html")
    ("interp" "ref-interp.html")
    ("interpGrp" "ref-interpGrp.html")
    ("interpretation" "ref-interpretation.html")
    ("item" "ref-item.html")
    ("join" "ref-join.html")
    ("joinGrp" "ref-joinGrp.html")
    ("keywords" "ref-keywords.html")
    ("kinesic" "ref-kinesic.html")
    ("l" "ref-l.html")
    ("label" "ref-label.html")
    ("lacunaEnd" "ref-lacunaEnd.html")
    ("lacunaStart" "ref-lacunaStart.html")
    ("lang" "ref-lang.html")
    ("langKnowledge" "ref-langKnowledge.html")
    ("langKnown" "ref-langKnown.html")
    ("langUsage" "ref-langUsage.html")
    ("language" "ref-language.html")
    ("layout" "ref-layout.html")
    ("layoutDesc" "ref-layoutDesc.html")
    ("lb" "ref-lb.html")
    ("lbl" "ref-lbl.html")
    ("leaf" "ref-leaf.html")
    ("lem" "ref-lem.html")
    ("lg" "ref-lg.html")
    ("licence" "ref-licence.html")
    ("line" "ref-line.html")
    ("link" "ref-link.html")
    ("linkGrp" "ref-linkGrp.html")
    ("list" "ref-list.html")
    ("listApp" "ref-listApp.html")
    ("listBibl" "ref-listBibl.html")
    ("listChange" "ref-listChange.html")
    ("listEvent" "ref-listEvent.html")
    ("listForest" "ref-listForest.html")
    ("listNym" "ref-listNym.html")
    ("listOrg" "ref-listOrg.html")
    ("listPerson" "ref-listPerson.html")
    ("listPlace" "ref-listPlace.html")
    ("listPrefixDef" "ref-listPrefixDef.html")
    ("listRef" "ref-listRef.html")
    ("listRelation" "ref-listRelation.html")
    ("listTranspose" "ref-listTranspose.html")
    ("listWit" "ref-listWit.html")
    ("localName" "ref-localName.html")
    ("locale" "ref-locale.html")
    ("location" "ref-location.html")
    ("locus" "ref-locus.html")
    ("locusGrp" "ref-locusGrp.html")
    ("m" "ref-m.html")
    ("macro.anyXML" "ref-macro.anyXML.html")
    ("macro.limitedContent" "ref-macro.limitedContent.html")
    ("macro.paraContent" "ref-macro.paraContent.html")
    ("macro.phraseSeq" "ref-macro.phraseSeq.html")
    ("macro.phraseSeq.limited" "ref-macro.phraseSeq.limited.html")
    ("macro.schemaPattern" "ref-macro.schemaPattern.html")
    ("macro.specialPara" "ref-macro.specialPara.html")
    ("macro.xtext" "ref-macro.xtext.html")
    ("macroRef" "ref-macroRef.html")
    ("macroSpec" "ref-macroSpec.html")
    ("mapping" "ref-mapping.html")
    ("material" "ref-material.html")
    ("measure" "ref-measure.html")
    ("measureGrp" "ref-measureGrp.html")
    ("media" "ref-media.html")
    ("meeting" "ref-meeting.html")
    ("memberOf" "ref-memberOf.html")
    ("mentioned" "ref-mentioned.html")
    ("metDecl" "ref-metDecl.html")
    ("metSym" "ref-metSym.html")
    ("metamark" "ref-metamark.html")
    ("milestone" "ref-milestone.html")
    ("mod" "ref-mod.html")
    ("model.addrPart" "ref-model.addrPart.html")
    ("model.addressLike" "ref-model.addressLike.html")
    ("model.applicationLike" "ref-model.applicationLike.html")
    ("model.availabilityPart" "ref-model.availabilityPart.html")
    ("model.biblLike" "ref-model.biblLike.html")
    ("model.biblPart" "ref-model.biblPart.html")
    ("model.castItemPart" "ref-model.castItemPart.html")
    ("model.catDescPart" "ref-model.catDescPart.html")
    ("model.certLike" "ref-model.certLike.html")
    ("model.choicePart" "ref-model.choicePart.html")
    ("model.common" "ref-model.common.html")
    ("model.contentPart" "ref-model.contentPart.html")
    ("model.correspActionPart" "ref-model.correspActionPart.html")
    ("model.correspContextPart" "ref-model.correspContextPart.html")
    ("model.correspDescPart" "ref-model.correspDescPart.html")
    ("model.dateLike" "ref-model.dateLike.html")
    ("model.descLike" "ref-model.descLike.html")
    ("model.dimLike" "ref-model.dimLike.html")
    ("model.div1Like" "ref-model.div1Like.html")
    ("model.div2Like" "ref-model.div2Like.html")
    ("model.div3Like" "ref-model.div3Like.html")
    ("model.div4Like" "ref-model.div4Like.html")
    ("model.div5Like" "ref-model.div5Like.html")
    ("model.div6Like" "ref-model.div6Like.html")
    ("model.div7Like" "ref-model.div7Like.html")
    ("model.divBottom" "ref-model.divBottom.html")
    ("model.divBottomPart" "ref-model.divBottomPart.html")
    ("model.divGenLike" "ref-model.divGenLike.html")
    ("model.divLike" "ref-model.divLike.html")
    ("model.divPart" "ref-model.divPart.html")
    ("model.divPart.spoken" "ref-model.divPart.spoken.html")
    ("model.divTop" "ref-model.divTop.html")
    ("model.divTopPart" "ref-model.divTopPart.html")
    ("model.divWrapper" "ref-model.divWrapper.html")
    ("model.editorialDeclPart" "ref-model.editorialDeclPart.html")
    ("model.egLike" "ref-model.egLike.html")
    ("model.emphLike" "ref-model.emphLike.html")
    ("model.encodingDescPart" "ref-model.encodingDescPart.html")
    ("model.entryLike" "ref-model.entryLike.html")
    ("model.entryPart" "ref-model.entryPart.html")
    ("model.entryPart.top" "ref-model.entryPart.top.html")
    ("model.featureVal.complex" "ref-model.featureVal.complex.html")
    ("model.featureVal" "ref-model.featureVal.html")
    ("model.featureVal.single" "ref-model.featureVal.single.html")
    ("model.formPart" "ref-model.formPart.html")
    ("model.frontPart.drama" "ref-model.frontPart.drama.html")
    ("model.frontPart" "ref-model.frontPart.html")
    ("model.gLike" "ref-model.gLike.html")
    ("model.global.edit" "ref-model.global.edit.html")
    ("model.global" "ref-model.global.html")
    ("model.global.meta" "ref-model.global.meta.html")
    ("model.global.spoken" "ref-model.global.spoken.html")
    ("model.glossLike" "ref-model.glossLike.html")
    ("model.gramPart" "ref-model.gramPart.html")
    ("model.graphicLike" "ref-model.graphicLike.html")
    ("model.headLike" "ref-model.headLike.html")
    ("model.hiLike" "ref-model.hiLike.html")
    ("model.highlighted" "ref-model.highlighted.html")
    ("model.imprintPart" "ref-model.imprintPart.html")
    ("model.inter" "ref-model.inter.html")
    ("model.lLike" "ref-model.lLike.html")
    ("model.lPart" "ref-model.lPart.html")
    ("model.labelLike" "ref-model.labelLike.html")
    ("model.limitedPhrase" "ref-model.limitedPhrase.html")
    ("model.linePart" "ref-model.linePart.html")
    ("model.listLike" "ref-model.listLike.html")
    ("model.measureLike" "ref-model.measureLike.html")
    ("model.milestoneLike" "ref-model.milestoneLike.html")
    ("model.morphLike" "ref-model.morphLike.html")
    ("model.msItemPart" "ref-model.msItemPart.html")
    ("model.msQuoteLike" "ref-model.msQuoteLike.html")
    ("model.nameLike.agent" "ref-model.nameLike.agent.html")
    ("model.nameLike" "ref-model.nameLike.html")
    ("model.noteLike" "ref-model.noteLike.html")
    ("model.oddDecl" "ref-model.oddDecl.html")
    ("model.oddRef" "ref-model.oddRef.html")
    ("model.offsetLike" "ref-model.offsetLike.html")
    ("model.orgPart" "ref-model.orgPart.html")
    ("model.orgStateLike" "ref-model.orgStateLike.html")
    ("model.pLike.front" "ref-model.pLike.front.html")
    ("model.pLike" "ref-model.pLike.html")
    ("model.pPart.data" "ref-model.pPart.data.html")
    ("model.pPart.edit" "ref-model.pPart.edit.html")
    ("model.pPart.editorial" "ref-model.pPart.editorial.html")
    ("model.pPart.msdesc" "ref-model.pPart.msdesc.html")
    ("model.pPart.transcriptional" "ref-model.pPart.transcriptional.html")
    ("model.persEventLike" "ref-model.persEventLike.html")
    ("model.persNamePart" "ref-model.persNamePart.html")
    ("model.persStateLike" "ref-model.persStateLike.html")
    ("model.personLike" "ref-model.personLike.html")
    ("model.personPart" "ref-model.personPart.html")
    ("model.phrase" "ref-model.phrase.html")
    ("model.phrase.xml" "ref-model.phrase.xml.html")
    ("model.physDescPart" "ref-model.physDescPart.html")
    ("model.placeEventLike" "ref-model.placeEventLike.html")
    ("model.placeLike" "ref-model.placeLike.html")
    ("model.placeNamePart" "ref-model.placeNamePart.html")
    ("model.placeStateLike" "ref-model.placeStateLike.html")
    ("model.profileDescPart" "ref-model.profileDescPart.html")
    ("model.ptrLike.form" "ref-model.ptrLike.form.html")
    ("model.ptrLike" "ref-model.ptrLike.html")
    ("model.publicationStmtPart.agency" "ref-model.publicationStmtPart.agency.html")
    ("model.publicationStmtPart.detail" "ref-model.publicationStmtPart.detail.html")
    ("model.qLike" "ref-model.qLike.html")
    ("model.quoteLike" "ref-model.quoteLike.html")
    ("model.rdgLike" "ref-model.rdgLike.html")
    ("model.rdgPart" "ref-model.rdgPart.html")
    ("model.recordingPart" "ref-model.recordingPart.html")
    ("model.resourceLike" "ref-model.resourceLike.html")
    ("model.respLike" "ref-model.respLike.html")
    ("model.segLike" "ref-model.segLike.html")
    ("model.settingPart" "ref-model.settingPart.html")
    ("model.sourceDescPart" "ref-model.sourceDescPart.html")
    ("model.specDescLike" "ref-model.specDescLike.html")
    ("model.stageLike" "ref-model.stageLike.html")
    ("model.teiHeaderPart" "ref-model.teiHeaderPart.html")
    ("model.textDescPart" "ref-model.textDescPart.html")
    ("model.titlepagePart" "ref-model.titlepagePart.html")
    ("moduleRef" "ref-moduleRef.html")
    ("moduleSpec" "ref-moduleSpec.html")
    ("monogr" "ref-monogr.html")
    ("mood" "ref-mood.html")
    ("move" "ref-move.html")
    ("msContents" "ref-msContents.html")
    ("msDesc" "ref-msDesc.html")
    ("msIdentifier" "ref-msIdentifier.html")
    ("msItem" "ref-msItem.html")
    ("msItemStruct" "ref-msItemStruct.html")
    ("msName" "ref-msName.html")
    ("msPart" "ref-msPart.html")
    ("musicNotation" "ref-musicNotation.html")
    ("name" "ref-name.html")
    ("nameLink" "ref-nameLink.html")
    ("namespace" "ref-namespace.html")
    ("nationality" "ref-nationality.html")
    ("node" "ref-node.html")
    ("normalization" "ref-normalization.html")
    ("notatedMusic" "ref-notatedMusic.html")
    ("note" "ref-note.html")
    ("notesStmt" "ref-notesStmt.html")
    ("num" "ref-num.html")
    ("number" "ref-number.html")
    ("numeric" "ref-numeric.html")
    ("nym" "ref-nym.html")
    ("oRef" "ref-oRef.html")
    ("oVar" "ref-oVar.html")
    ("objectDesc" "ref-objectDesc.html")
    ("objectType" "ref-objectType.html")
    ("occupation" "ref-occupation.html")
    ("offset" "ref-offset.html")
    ("opener" "ref-opener.html")
    ("org" "ref-org.html")
    ("orgName" "ref-orgName.html")
    ("orig" "ref-orig.html")
    ("origDate" "ref-origDate.html")
    ("origPlace" "ref-origPlace.html")
    ("origin" "ref-origin.html")
    ("orth" "ref-orth.html")
    ("p" "ref-p.html")
    ("pRef" "ref-pRef.html")
    ("pVar" "ref-pVar.html")
    ("particDesc" "ref-particDesc.html")
    ("pause" "ref-pause.html")
    ("pb" "ref-pb.html")
    ("pc" "ref-pc.html")
    ("per" "ref-per.html")
    ("performance" "ref-performance.html")
    ("persName" "ref-persName.html")
    ("person" "ref-person.html")
    ("personGrp" "ref-personGrp.html")
    ("phr" "ref-phr.html")
    ("physDesc" "ref-physDesc.html")
    ("place" "ref-place.html")
    ("placeName" "ref-placeName.html")
    ("population" "ref-population.html")
    ("pos" "ref-pos.html")
    ("postBox" "ref-postBox.html")
    ("postCode" "ref-postCode.html")
    ("postscript" "ref-postscript.html")
    ("precision" "ref-precision.html")
    ("prefixDef" "ref-prefixDef.html")
    ("preparedness" "ref-preparedness.html")
    ("principal" "ref-principal.html")
    ("profileDesc" "ref-profileDesc.html")
    ("projectDesc" "ref-projectDesc.html")
    ("prologue" "ref-prologue.html")
    ("pron" "ref-pron.html")
    ("provenance" "ref-provenance.html")
    ("ptr" "ref-ptr.html")
    ("pubPlace" "ref-pubPlace.html")
    ("publicationStmt" "ref-publicationStmt.html")
    ("publisher" "ref-publisher.html")
    ("punctuation" "ref-punctuation.html")
    ("purpose" "ref-purpose.html")
    ("q" "ref-q.html")
    ("quotation" "ref-quotation.html")
    ("quote" "ref-quote.html")
    ("rdg" "ref-rdg.html")
    ("rdgGrp" "ref-rdgGrp.html")
    ("re" "ref-re.html")
    ("recordHist" "ref-recordHist.html")
    ("recording" "ref-recording.html")
    ("recordingStmt" "ref-recordingStmt.html")
    ("redo" "ref-redo.html")
    ("ref" "ref-ref.html")
    ("refState" "ref-refState.html")
    ("refsDecl" "ref-refsDecl.html")
    ("reg" "ref-reg.html")
    ("region" "ref-region.html")
    ("relatedItem" "ref-relatedItem.html")
    ("relation" "ref-relation.html")
    ("remarks" "ref-remarks.html")
    ("rendition" "ref-rendition.html")
    ("repository" "ref-repository.html")
    ("residence" "ref-residence.html")
    ("resp" "ref-resp.html")
    ("respStmt" "ref-respStmt.html")
    ("respons" "ref-respons.html")
    ("restore" "ref-restore.html")
    ("retrace" "ref-retrace.html")
    ("revisionDesc" "ref-revisionDesc.html")
    ("rhyme" "ref-rhyme.html")
    ("role" "ref-role.html")
    ("roleDesc" "ref-roleDesc.html")
    ("roleName" "ref-roleName.html")
    ("root" "ref-root.html")
    ("row" "ref-row.html")
    ("rs" "ref-rs.html")
    ("rubric" "ref-rubric.html")
    ("s" "ref-s.html")
    ("said" "ref-said.html")
    ("salute" "ref-salute.html")
    ("samplingDecl" "ref-samplingDecl.html")
    ("schemaSpec" "ref-schemaSpec.html")
    ("scriptDesc" "ref-scriptDesc.html")
    ("scriptNote" "ref-scriptNote.html")
    ("scriptStmt" "ref-scriptStmt.html")
    ("seal" "ref-seal.html")
    ("sealDesc" "ref-sealDesc.html")
    ("secFol" "ref-secFol.html")
    ("seg" "ref-seg.html")
    ("segmentation" "ref-segmentation.html")
    ("sense" "ref-sense.html")
    ("sequence" "ref-sequence.html")
    ("series" "ref-series.html")
    ("seriesStmt" "ref-seriesStmt.html")
    ("set" "ref-set.html")
    ("setting" "ref-setting.html")
    ("settingDesc" "ref-settingDesc.html")
    ("settlement" "ref-settlement.html")
    ("sex" "ref-sex.html")
    ("shift" "ref-shift.html")
    ("sic" "ref-sic.html")
    ("signatures" "ref-signatures.html")
    ("signed" "ref-signed.html")
    ("soCalled" "ref-soCalled.html")
    ("socecStatus" "ref-socecStatus.html")
    ("sound" "ref-sound.html")
    ("source" "ref-source.html")
    ("sourceDesc" "ref-sourceDesc.html")
    ("sourceDoc" "ref-sourceDoc.html")
    ("sp" "ref-sp.html")
    ("spGrp" "ref-spGrp.html")
    ("space" "ref-space.html")
    ("span" "ref-span.html")
    ("spanGrp" "ref-spanGrp.html")
    ("speaker" "ref-speaker.html")
    ("specDesc" "ref-specDesc.html")
    ("specGrp" "ref-specGrp.html")
    ("specGrpRef" "ref-specGrpRef.html")
    ("specList" "ref-specList.html")
    ("sponsor" "ref-sponsor.html")
    ("stage" "ref-stage.html")
    ("stamp" "ref-stamp.html")
    ("state" "ref-state.html")
    ("stdVals" "ref-stdVals.html")
    ("street" "ref-street.html")
    ("stress" "ref-stress.html")
    ("string" "ref-string.html")
    ("styleDefDecl" "ref-styleDefDecl.html")
    ("subc" "ref-subc.html")
    ("subst" "ref-subst.html")
    ("substJoin" "ref-substJoin.html")
    ("summary" "ref-summary.html")
    ("superEntry" "ref-superEntry.html")
    ("supplied" "ref-supplied.html")
    ("support" "ref-support.html")
    ("supportDesc" "ref-supportDesc.html")
    ("surface" "ref-surface.html")
    ("surfaceGrp" "ref-surfaceGrp.html")
    ("surname" "ref-surname.html")
    ("surplus" "ref-surplus.html")
    ("surrogates" "ref-surrogates.html")
    ("syll" "ref-syll.html")
    ("symbol" "ref-symbol.html")
    ("table" "ref-table.html")
    ("tag" "ref-tag.html")
    ("tagUsage" "ref-tagUsage.html")
    ("tagsDecl" "ref-tagsDecl.html")
    ("taxonomy" "ref-taxonomy.html")
    ("tech" "ref-tech.html")
    ("teiCorpus" "ref-teiCorpus.html")
    ("teiHeader" "ref-teiHeader.html")
    ("term" "ref-term.html")
    ("terrain" "ref-terrain.html")
    ("text" "ref-text.html")
    ("textClass" "ref-textClass.html")
    ("textDesc" "ref-textDesc.html")
    ("textLang" "ref-textLang.html")
    ("textNode" "ref-textNode.html")
    ("then" "ref-then.html")
    ("time" "ref-time.html")
    ("timeline" "ref-timeline.html")
    ("title" "ref-title.html")
    ("titlePage" "ref-titlePage.html")
    ("titlePart" "ref-titlePart.html")
    ("titleStmt" "ref-titleStmt.html")
    ("tns" "ref-tns.html")
    ("trailer" "ref-trailer.html")
    ("trait" "ref-trait.html")
    ("transpose" "ref-transpose.html")
    ("tree" "ref-tree.html")
    ("triangle" "ref-triangle.html")
    ("typeDesc" "ref-typeDesc.html")
    ("typeNote" "ref-typeNote.html")
    ("u" "ref-u.html")
    ("unclear" "ref-unclear.html")
    ("undo" "ref-undo.html")
    ("unicodeName" "ref-unicodeName.html")
    ("usg" "ref-usg.html")
    ("vAlt" "ref-vAlt.html")
    ("vColl" "ref-vColl.html")
    ("vDefault" "ref-vDefault.html")
    ("vLabel" "ref-vLabel.html")
    ("vMerge" "ref-vMerge.html")
    ("vNot" "ref-vNot.html")
    ("vRange" "ref-vRange.html")
    ("val" "ref-val.html")
    ("valDesc" "ref-valDesc.html")
    ("valItem" "ref-valItem.html")
    ("valList" "ref-valList.html")
    ("value" "ref-value.html")
    ("variantEncoding" "ref-variantEncoding.html")
    ("view" "ref-view.html")
    ("vocal" "ref-vocal.html")
    ("w" "ref-w.html")
    ("watermark" "ref-watermark.html")
    ("when" "ref-when.html")
    ("width" "ref-width.html")
    ("wit" "ref-wit.html")
    ("witDetail" "ref-witDetail.html")
    ("witEnd" "ref-witEnd.html")
    ("witStart" "ref-witStart.html")
    ("witness" "ref-witness.html")
    ("writing" "ref-writing.html")
    ("xr" "ref-xr.html")
    ("zone" "ref-zone.html")))

(defun tei-html-docs-p5-get-element-name ()
  "Gets the name of the element close to point."
  (save-match-data
    (save-excursion
      (if (and (re-search-backward "<[^!?/>]" nil t)
	       (re-search-forward "\\=<\\([^!?/>][^ \t\r\n>]*\\)" nil t))
	  (match-string 1)))))

(defun tei-html-docs-p5-element-at-point ()
  "Read the documentation for element at point."
  (interactive)
  (let ((el (tei-html-docs-p5-get-element-name)))
    (if el
	(tei-html-docs-p5-element el)
      (error "Couldn't find an element to look up here, sorry"))))

(defun tei-html-docs-p5-element (element)
  "Lookup ELEMENT in the TEI documentation.

If ELEMENT is not specified, prompt with completion."
  (interactive
   (list (completing-read
          "Lookup info for element: "
          (mapcar 'car
                  tei-html-docs-p5-element-alist)
          nil nil (tei-html-docs-p5-get-element-name))))
  (let ((file (cadr (assoc (or element (tei-html-docs-p5-get-element-name))
			   tei-html-docs-p5-element-alist))))
    (if file
	(funcall tei-html-docs-p5-view-command
		 (if tei-html-docs-p5-dir
		     (concat "file://" (concat tei-html-docs-p5-dir file))
		   (concat tei-html-docs-p5-url file)))
      (message "Element %s not found in docs" name))))
  
(defun tei-html-docs-p5-make-elements-list ()
  "Generate the index of element-name to the filename of its documentation."
  (when tei-html-docs-p5-dir
    (let ((files (directory-files tei-html-docs-p5-dir t "^ref-"))
	  index
	  failed)
      (dolist (file files (nreverse index))
	(with-temp-buffer
	  (insert-file-contents file)
	  (goto-char (point-min))
	  (if (and (search-forward "class=\"oddSpec\"" nil t)
		   (search-backward "<h3")
		   (xmltok-forward)
		   (= (length xmltok-attributes) 2)
		   (string= (xmltok-attribute-local-name (elt xmltok-attributes 1)) "id"))
	      (push
               (list
                (xmltok-attribute-value (elt xmltok-attributes 1))
                (file-name-nondirectory file))
               index)
	    (message (format "Failed to find useful stuff for: %s" file))))))))

;;;; time needed for the 2.8.0 guidelines:
;; (dotimes (i 20)
;;   (tei-html-docs-p5-make-elements-list))
;; tei-html-docs-p5-make-elements-list  20          13.730247291  0.6865123645

;; (setq soup (tei-html-docs-p5-make-elements-list))
;; (length soup)
;; (setq soup (let ((tei-html-docs-p5-dir "/usr/share/doc/tei-p5-doc/it/html/")) (tei-html-docs-p5-make-elements-list)))
;; (length soup)
;; (setq soup (let ((tei-html-docs-p5-dir "/usr/share/doc/tei-p5-doc/ja/html/")) (tei-html-docs-p5-make-elements-list)))
;; (length soup)

(provide 'tei-html-docs-p5)

;;; tei-html-docs-p5 ends here


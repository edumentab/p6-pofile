use v6;
use Test;
use POFile;

my ($PO, $result);

$PO = q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr ""

#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr ""

#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'msgid, msgstr with source reference comment';

$PO = q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr "Globularna jata"

#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr "Gasne magline"

#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr "Planetarne magline"
END

lives-ok { $result = POFile.parse($PO) }, 'msgid, msgstr with source reference comment';

$PO = q:to/END/;
#: indimenu.cpp:96
msgid ""
"No INDI devices currently running. To run devices, please select devices "
"from the Device Manager in the devices menu."
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Multi-line msgid';

$PO = q:to/END/;
#. TRANSLATORS: A test phrase with all letters of the English alphabet.
#. Replace it with a sample text in your language, such that it is
#. representative of language's writing system.
#: kdeui/fonts/kfontchooser.cpp:382
msgid "The Quick Brown Fox Jumps Over The Lazy Dog"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Extracted comments';

$PO = q:to/END/;
#: tools/observinglist.cpp:700
msgctxt "First letter in 'Scope'"
msgid "S"
msgstr ""

#: skycomponents/horizoncomponent.cpp:429
msgctxt "South"
msgid "S"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Message context';

$PO = q:to/END/;
# Wikipedia says that ‘etrurski’ is our name for this script.
#: viewpart/UnicodeBlocks.h:151
msgid "Old Italic"
msgstr "etrurski"
END

lives-ok { $result = POFile.parse($PO) }, 'Translator comments';

$PO = q:to/END/;
#: skycomponents/constellationlines.cpp:106
#, kde-format
msgid "No star named %1 found."
msgstr "Nema zvezde po imenu %1."
END

lives-ok { $result = POFile.parse($PO) }, 'Translator comments';

$PO = q:to/END/;
#. Tag: title
#: blackbody.docbook:13
msgid "<title>Blackbody Radiation</title>"
msgstr ""

#. Tag: para
#: geocoords.docbook:28
msgid ""
"The Equator is obviously an important part of this coordinate system; "
"it represents the <emphasis>zeropoint</emphasis> of the latitude angle, "
"and the halfway point between the poles. The Equator is the "
"<firstterm>Fundamental Plane</firstterm> of the geographic coordinate "
"system. <link linkend='ai-skycoords'>All Spherical</link> Coordinate "
"Systems define such a Fundamental Plane."
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Markup';

$PO = q:to/END/;
#: kstars_i18n.cpp:3591
msgid "The \"face\" on Mars"
msgstr "\"Lice\" na Marsu"
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - double quote';

$PO = q:to/END/;
#: kstarsinit.cpp:699
msgid ""
"The initial position is below the horizon.\n"
"Would you like to reset to the default position?"
msgstr ""
"Početni položaj je ispod horizonta.\n"
"Želite li da vratite na podrazumevani?"
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - newline';

$PO = q:to/END/;
msgid ""
"\t\\\t"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - tab and backslash';

$PO = q:to/END/;
#: kstarsinit.cpp:163
msgid "Set Focus &Manually..."
msgstr "フォーカスを手動でセット(&M)..."
END

lives-ok { $result = POFile.parse($PO) }, 'Accelerator';

$PO = q:to/END/;
#: kspopupmenu.cpp:203
msgid "Center && Track"
msgstr ""

#. Tag: phrase
#: config.docbook:137
msgid "<phrase>Configure &kstars; Window</phrase>"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Accelerator 2';

$PO = q:to/END/;
#: mainwindow.cpp:127
#, kde-format
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"

msgid "<phrase>Configure &kstars; Window</phrase>"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Plural forms';

$PO = q:to/END/;
#: src/somwidget_impl.cpp:120
#, fuzzy
#| msgid "Elements with boiling point around this temperature:"
msgid "Elements with melting point around this temperature:"
msgstr "Elementi s tačkom ključanja u blizini ove temperature:"
END

lives-ok { $result = POFile.parse($PO) }, 'Fuzzy';

$PO = q:to/END/;
#: kstarsinit.cpp:451
#, fuzzy
#| msgctxt "Constellation Line"
#| msgid "Constell. Line"
msgctxt "Toggle Constellation Lines in the display"
msgid "Const. Lines"
msgstr "Linija sazvežđa"
END

lives-ok { $result = POFile.parse($PO) }, 'Fuzzy 2';

$PO = q:to/END/;
#~ msgid "Set the telescope longitude and latitude."
#~ msgstr "Postavi geo. dužinu i širinu teleskopa."
END

lives-ok { $result = POFile.parse($PO) }, 'Obsolete messages';

done-testing;

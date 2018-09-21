use v6;

class POFile::Entry {...}
class POFile {...}

grammar PO {
    token TOP { [<PO-rule> | <obsolete-message>]* % "\n"* }
    token obsolete-message { '#~ ' <comment-text> "\n" }
    token PO-rule { <comment-section>* <block> }
    token comment-section { [<source-ref-comment> | <extracted-comment> |
                             <translator-comment> | <format-directive>  |
                             <previous-string-comment>
                            ] "\n" }
    token block { <msgctxt>? <msgid> <msgid-plural>? <msgstr>+ }
    token source-ref-comment { '#: ' <comment-text> }
    token extracted-comment  { '#. ' <comment-text> }
    token translator-comment { '# '  <comment-text> }
    token format-directive   { '#, ' <comment-text> }
    token previous-string-comment { '#| ' <fuzzy-marker> ' ' <comment-text> }
    token fuzzy-marker { 'msgid' | 'msgctxt' }
    token msgctxt { 'msgctxt ' <item-text> "\n"  }
    token msgid { 'msgid ' <item-text> "\n"  }
    token msgid-plural { 'msgid_plural ' <item-text> "\n"  }
    token msgstr { 'msgstr' <pluralizer>? ' ' <item-text> "\n" }
    token pluralizer { '[' \d+ ']' }
    token comment-text { <-[\n]>* }
    token item-text { <long-form> | <-[\n]>+ }
    token long-form { '""' "\n" <quoted-str>+ % "\n" }
    token quoted-str { '"' [<escaped> | <-["]>]* '"' }
    token escaped { '\"' };
}

class PO::Actions {
    method TOP($/) {
        my @obsolete-messages = $<obsolete-message>>>.made;
        my @PO;
        for $<PO-rule> -> $rule {
            my @args = $rule.made;
            @PO.push: POFile::Entry.new(|%@args);
        }
        make (@PO, @obsolete-messages);
    }

    method PO-rule($/) {
        my @args;
        my ($reference = '', $extracted   = '', $comment = '',
            $format    = '', $fuzzy-msgid = '', $fuzzy-msgctxt = '');
        for $<comment-section> {
            with $_<source-ref-comment> {
                $reference ~= $_.made;
            } orwith $_<extracted-comment> {
                $extracted ~= $_.made;
            } orwith $_<translator-comment> {
                $comment ~= $_.made;
            } orwith $_<format-directive> {
                $format ~= $_.made;
            } orwith $_<previous-string-comment> {
                if $_<fuzzy-marker> eq 'msgid' {
                    $fuzzy-msgid ~= $_.made;
                } else {
                    $fuzzy-msgctxt ~= $_.made;
                }
            }
        }

        @args.push(Pair.new('reference', $reference)) if $reference;
        @args.push(Pair.new('extracted', $extracted)) if $extracted;
        @args.push(Pair.new('comment', $comment)) if $comment;
        @args.push(Pair.new('format-style', $format)) if $format;
        @args.push(Pair.new('fuzzy-msgid', $fuzzy-msgid)) if $fuzzy-msgid;
        @args.push(Pair.new('fuzzy-msgctxt', $fuzzy-msgctxt)) if $fuzzy-msgctxt;
        @args.push(|$<block>.made);
        make @args;
    }

    method comment-section($/) {
        with $<source-ref-comment> {
            make Pair.new('reference', .made);
        } orwith $<extracted-comment> {
            make Pair.new('extracted', .made);
        } orwith $<translator-comment> {
            make Pair.new('comment', .made);
        } orwith $<format-directive> {
            make Pair.new('format-style', .made);
        } orwith $<previous-string-comment> {
            my $is-id = $<previous-string-comment><fuzzy-marker> eq 'msgid';
            make Pair.new($is-id ?? 'fuzzy-msgid' !! 'fuzzy-msgctxt', .made);
        } else {
            make Nil;
        }
    }

    method block($/) {
        my @args;
        with $<msgctxt> {
            @args.push(Pair.new('msgctxt', $_.made));
        }
        @args.push(Pair.new('msgid', $<msgid>.made));
        with $<msgid-plural> {
            @args.push(Pair.new('msgid-plural', $<msgid-plural>.made));
            @args.push(Pair.new('msgstr', $<msgstr>.map(*.made).Array));
        } else {
            @args.push(Pair.new('msgstr', $<msgstr>[0].made));
        }
        make @args;
    }

    method source-ref-comment($/)      { make ~$<comment-text> }
    method extracted-comment($/)       { make ~$<comment-text> }
    method translator-comment($/)      { make ~$<comment-text> }
    method format-directive($/)        { make ~$<comment-text> }
    method previous-string-comment($/) { make ~$<comment-text> }

    method msgctxt($/)      { make $<item-text>.made }
    method msgid($/)        { make $<item-text>.made }
    method msgid-plural($/) { make $<item-text>.made }
    method msgstr($/)       { make $<item-text>.made }

    method item-text($/) {
        with $<long-form> {
            make $_<quoted-str>.map(*.substr(1, *-1)).join;
        } else {
            make ~$/.substr(1, *-1);
        }
    }

    method obsolete-message($/) { make ~$<comment-text> }
}

class POFile::Entry {
    # msgid
    has Str $.msgid is rw;
    # msgid_plural
    has Str $.msgid-plural is rw;
    # msgstr, plural or single
    subset MsgStr where Array|Str;
    has MsgStr $.msgstr is rw;
    # msgctxt
    has Str $.msgctxt is rw;
    # #:
    has Str $.reference is rw;
    # #.
    has Str $.extracted is rw;
    # #
    has Str $.comment is rw;
    # #,
    has Str $.format-style is rw;
    # #|
    has Str $.fuzzy-msgid is rw;
    has Str $.fuzzy-msgctxt is rw;

    method Str() {}

    method parse(Str $input) {
        my $m = PO.parse($input, :rule<PO-rule>, actions => PO::Actions);
        die "Cannot parse item" unless $m.defined;
        my @args = $m.made;
        self.bless(|%@args);
    }
}

class POFile does Associative does Positional {
    has @!items;
    has %!entries;
    has @.obsolete-messages;

    submethod BUILD(:@!items, :%!entries, :@!obsolete-messages) {}

    # Associative && Positional
    method of() { POFile::Entry }
    # Associative
    method AT-KEY($key) { %!entries{$key} }
    method EXISTS-KEY($key) { %!entries{$key}:exists }
    # Positional
    method AT-POS($index) { @!items[$index] }
    method EXISTS-POS($index) { 0 < $index < @!items.size }

    method Str() {}

    method parse(Str $input) {
        my $m = PO.parse($input, actions => PO::Actions);
        die "Cannot parse item" unless $m.defined;
        my $result = $m.made;
        my @obsolete-messages = $result[1];
        my (@items, %entries);
        for $result[0] -> $rule {
            @items.push: $rule;
            %entries{$rule.msgid} = $rule;
        }
        self.bless(:@obsolete-messages, :@items, :%entries);
    }

    method load(Str() $path) {
        unless $path.IO.e {
            die "File $path does not exist";
        }
        self.parse(slurp $path)
    }

    method save(Str() $path) {
        spurt $path, self.Str;
    }
}

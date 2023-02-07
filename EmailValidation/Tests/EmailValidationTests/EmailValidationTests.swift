import XCTest
import Parsing
@testable import EmailValidation

final class EmailValidationTests: XCTestCase {
    // MARK: RFC5322 (no obsolete)
    func testValidEmails() {
        // Local part validation
        XCTAssertEqual(try Email("user@example.com").localPart, "user")
        XCTAssertEqual(try Email("!#$%&'*+-/=?^_`{|}~@example.com").localPart, "!#$%&'*+-/=?^_`{|}~")
        XCTAssertEqual(try Email("user.name+tag@example.com").localPart, "user.name+tag")
        XCTAssertEqual(try Email("\"user name\\@tag \\\"falseQuote\"@example.com").localPart, "\"user name\\@tag \\\"falseQuote\"")
        // comments are discouraged but not prohibited by RFC5322.
        XCTAssertEqual(try Email("()empty.comment@example.com").localPart, "()empty.comment")
        XCTAssertEqual(try Email("(this is a comment)me@example.com").localPart, "(this is a comment)me")
        XCTAssertEqual(try Email("(this is a (nested comment))me@example.com").localPart, "(this is a (nested comment))me")
        XCTAssertEqual(try Email("(this is <a> comment)me@example.com").localPart, "(this is <a> comment)me")
        XCTAssertEqual(try Email("me(this is a comment)@example.com").localPart, "me(this is a comment)")
        XCTAssertEqual(try Email("(this is a comment)me(another)@example.com").localPart, "(this is a comment)me(another)")
        XCTAssertEqual(try Email("me(this is a (nested comment))@example.com").localPart, "me(this is a (nested comment))")
        XCTAssertEqual(try Email("me(this is <a> comment)@example.com").localPart, "me(this is <a> comment)")
        XCTAssertEqual(try Email("309d4696df38ff12c023600e3bc2bd4b@fakedomain.com").localPart, "309d4696df38ff12c023600e3bc2bd4b")
        XCTAssertEqual(try Email("ewiuhdghiufduhdvjhbajbkerwukhgjhvxbhvbsejskuadukfhgskjebf@gmail.net").localPart, "ewiuhdghiufduhdvjhbajbkerwukhgjhvxbhvbsejskuadukfhgskjebf")
        XCTAssertEqual(try Email("John Doe <john.doe@example.com>").localPart, "john.doe")
        XCTAssertEqual(try Email("\"John Doe\" <john.doe@example.com>").localPart, "john.doe")
        XCTAssertEqual(try Email("John Doe (this is <a> comment) <john.doe@example.com>").localPart, "john.doe")
        XCTAssertEqual(try Email("用户@example.com").localPart, "用户")
        XCTAssertEqual(try Email("H.B. Lewis <test@earthlink.net>").localPart, "test")

        // domain part validation
        XCTAssertEqual(try Email("user@example.com").domainPart, "example.com")
        XCTAssertEqual(try Email("用户@例子.测试").domainPart, "例子.测试")
        XCTAssertEqual(try Email("user@subdomain(comment).example.com").domainPart, "subdomain(comment).example.com")
        XCTAssertEqual(try Email("user@(comment)subdomain.example.com").domainPart, "(comment)subdomain.example.com")
        XCTAssertEqual(try Email("user@subdomain.(comment)example.com").domainPart, "subdomain.(comment)example.com")
        XCTAssertEqual(try Email("user@subdomain.example(comment).com").domainPart, "subdomain.example(comment).com")
        XCTAssertEqual(try Email("user@subdomain.example.com").domainPart, "subdomain.example.com")
        XCTAssertEqual(try Email("user@sub-domain.example.com").domainPart, "sub-domain.example.com")
        XCTAssertEqual(try Email("me.example@com").domainPart, "com")
        XCTAssertEqual(try Email("user@[123.123.123.123]").domainPart, "123.123.123.123")
        XCTAssertEqual(try Email("user@[127.000.000.001]").domainPart, "127.0.0.1")
        XCTAssertEqual(try Email("user@[IPv6:2001:db8::1]").domainPart, "2001:DB8::1")
        XCTAssertEqual(try Email("user@[IPv6:0000:0000:0000:0000:0000:0000:0000:0001]").domainPart, "::1")
        XCTAssertEqual(try Email("user@[IPv6:0123:4567:89AB:CDEF:0123:4567:89AB:CDEF]").domainPart, "123:4567:89AB:CDEF:123:4567:89AB:CDEF")

        XCTAssertNoThrow(try Email("\"Abc\\@def\"@example.com"))
        XCTAssertNoThrow(try Email("\"Fred Bloggs\"@example.com"))
        XCTAssertNoThrow(try Email("\"Joe\\\\Blow\"@example.com"))
        XCTAssertNoThrow(try Email("\"Abc@def\"@example.com"))
        XCTAssertNoThrow(try Email("customer/department=shipping@example.com"))
        XCTAssertNoThrow(try Email("$A12345@example.com"))
        XCTAssertNoThrow(try Email("!def!xyz%abc@example.com"))
        XCTAssertNoThrow(try Email("_somename@example.com"))
        XCTAssertNoThrow(try Email("valid.ipv4.addr@[123.1.72.10]"))
        XCTAssertNoThrow(try Email("valid.ipv6.addr@[IPv6:0::1]"))
        XCTAssertNoThrow(try Email("valid.ipv6.addr@[IPv6:2607:f0d0:1002:51::4]"))
        XCTAssertNoThrow(try Email("valid.ipv6.addr@[IPv6:fe80::230:48ff:fe33:bc33]"))
        XCTAssertNoThrow(try Email("valid.ipv6.addr@[IPv6:fe80:0000:0000:0000:0202:b3ff:fe1e:8329]"))

        // examples from wikipedia
        XCTAssertNoThrow(try Email("niceandsimple@example.com"))
        XCTAssertNoThrow(try Email("very.common@example.com"))
        XCTAssertNoThrow(try Email("a.little.lengthy.but.fine@dept.example.com"))
        XCTAssertNoThrow(try Email("disposable.style.email.with+symbol@example.com"))
        XCTAssertNoThrow(try Email("user@[IPv6:2001:db8:1ff::a0b:dbd0]"))
        XCTAssertNoThrow(try Email("\"much.more unusual\"@example.com"))
        XCTAssertNoThrow(try Email("\"very.unusual.@.unusual.com\"@example.com"))
        XCTAssertNoThrow(try Email("\"very.())):;<>[]\\\".VERY.\\\"very@\\\\ \\\"very\\\".unusual\"@strange.example.com"))
        XCTAssertNoThrow(try Email("postbox@com"))
        XCTAssertNoThrow(try Email("admin@mailserver1"))
        XCTAssertNoThrow(try Email("!#$%&'*+-/=?^_`{}|~@example.org"))
        XCTAssertNoThrow(try Email("\"()<>[]:));@\\\\\\\"!#$%&'*+-/=?^_`{}| ~.a\"@example.org"))
        XCTAssertNoThrow(try Email("\" \"@example.org"))

        // examples from https://github.com/Sembiance/email-validator
        XCTAssertNoThrow(try Email("\"\\e\\s\\c\\a\\p\\e\\d\"@sld.com"))
        XCTAssertNoThrow(try Email("\"back\\slash\"@sld.com"))
        XCTAssertNoThrow(try Email("\"escaped\\\"quote\"@sld.com"))
        XCTAssertNoThrow(try Email("\"quoted\"@sld.com"))
        XCTAssertNoThrow(try Email("\"quoted-at-sign@sld.org\"@sld.com"))
        XCTAssertNoThrow(try Email("&'*+-./=?^_{}~@other-valid-characters-in-local.net"))
        XCTAssertNoThrow(try Email("01234567890@numbers-in-local.net"))
        XCTAssertNoThrow(try Email("a@single-character-in-local.org"))
        XCTAssertNoThrow(try Email("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@letters-in-local.org"))
        XCTAssertNoThrow(try Email("backticksarelegit@test.com"))
        XCTAssertNoThrow(try Email("bracketed-IP-instead-of-domain@[127.0.0.1]"))
        XCTAssertNoThrow(try Email("country-code-tld@sld.rw"))
        XCTAssertNoThrow(try Email("country-code-tld@sld.uk"))
        XCTAssertNoThrow(try Email("letters-in-sld@123.com"))
        XCTAssertNoThrow(try Email("local@dash-in-sld.com"))
        XCTAssertNoThrow(try Email("local@sld.newTLD"))
        XCTAssertNoThrow(try Email("local@sub.domains.com"))
        XCTAssertNoThrow(try Email("mixed-1234-in-{+^}-local@sld.net"))
        XCTAssertNoThrow(try Email("one-character-third-level@a.example.com"))
        XCTAssertNoThrow(try Email("one-letter-sld@x.org"))
        XCTAssertNoThrow(try Email("punycode-numbers-in-tld@sld.xn--3e0b707e"))
        XCTAssertNoThrow(try Email("single-character-in-sld@x.org"))
        XCTAssertNoThrow(try Email("the-character-limit@for-each-part.of-the-domain.is-sixty-three-characters.this-is-exactly-sixty-three-characters-so-it-is-valid-blah-blah.com"))
        XCTAssertNoThrow(try Email("the-total-length@of-an-entire-address.cannot-be-longer-than-two-hundred-and-fifty-four-characters.and-this-address-is-254-characters-exactly.so-it-should-be-valid.and-im-going-to-add-some-more-words-here.to-increase-the-length-blah-blah-blah-blah-bla.org"))
        XCTAssertNoThrow(try Email("uncommon-tld@sld.mobi"))
        XCTAssertNoThrow(try Email("uncommon-tld@sld.museum"))
        XCTAssertNoThrow(try Email("uncommon-tld@sld.travel"))

        XCTAssertNoThrow(try Email("Pelé@example.com")) // Latin with diacritics
        XCTAssertNoThrow(try Email("伊昭傑@郵件.商務")) // Chinese
        XCTAssertNoThrow(try Email("राम@मोहन.ईन्फो")) // Hindi
        XCTAssertNoThrow(try Email("юзер@екзампл.ком")) // Ukranian
        XCTAssertNoThrow(try Email("θσερ@εχαμπλε.ψομ")) // Greek
        XCTAssertNoThrow(try Email("дядя_вася@деревня.рф")) // Russian

        #warning("Known deficiencies: newline characters anywhere, RFC 822/2822")
    }

    func testInvalidEmails() {
        XCTAssertThrowsError(try Email(""))
        XCTAssertThrowsError(try Email("invalid"))
        XCTAssertThrowsError(try Email("invalid@"))
        XCTAssertThrowsError(try Email("invalid @"))
        XCTAssertThrowsError(try Email("invalid@[555.666.777.888]"))
        XCTAssertThrowsError(try Email("invalid@[IPv6:123456]"))
        XCTAssertThrowsError(try Email("invalid@[127.0.0.1.]"))
        XCTAssertThrowsError(try Email("invalid@[127.0.0.1]."))
        XCTAssertThrowsError(try Email("invalid@[127.0.0.1]x"))

        // examples from wikipedia
        XCTAssertThrowsError(try Email("Abc.example.com"))
        XCTAssertThrowsError(try Email("A@b@c@example.com"))
        XCTAssertThrowsError(try Email("a\"b(c)d))e:f;g<h>i[j\\k]l@example.com"))
        XCTAssertThrowsError(try Email("just\"not\"right@example.com"))
        XCTAssertThrowsError(try Email("this is\"not\\allowed@example.com"))
        XCTAssertThrowsError(try Email("this\\ still\\\"not\\\\allowed@example.com"))
        XCTAssertThrowsError(try Email("i_like_underscore@but_its_not_allowed_in_this_part.example.com"))

        // examples from https://github.com/Sembiance/email-validator
        XCTAssertThrowsError(try Email("! #$%`|@invalid-characters-in-local.org"))
        XCTAssertThrowsError(try Email("())):;`|@more-invalid-characters-in-local.org"))
        XCTAssertThrowsError(try Email("* .local-starts-with-dot@sld.com"))
        XCTAssertThrowsError(try Email("<>@[]`|@even-more-invalid-characters-in-local.org"))
        XCTAssertThrowsError(try Email("@missing-local.org"))
        XCTAssertThrowsError(try Email("IP-and-port@127.0.0.1:25"))
        XCTAssertThrowsError(try Email("another-invalid-ip@127.0.0.256"))
        XCTAssertThrowsError(try Email("invalid"))
        XCTAssertThrowsError(try Email("invalid-characters-in-sld@! \"#$%()))/;<>_[]`|.org"))
        XCTAssertThrowsError(try Email("invalid-ip@127.0.0.1.26"))
        XCTAssertThrowsError(try Email("local-ends-with-dot.@sld.com"))
        XCTAssertThrowsError(try Email("missing-at-sign.net"))
        XCTAssertThrowsError(try Email("missing-sld@.com"))
        XCTAssertThrowsError(try Email("missing-tld@sld."))
        XCTAssertThrowsError(try Email("sld-ends-with-dash@sld-.com"))
        XCTAssertThrowsError(try Email("sld-starts-with-dashsh@-sld.com"))
        XCTAssertThrowsError(try Email("the-character-limit@for-each-part.of-the-domain.is-sixty-three-characters.this-is-exactly-sixty-four-characters-so-it-is-invalid-blah-blah.com"))
        XCTAssertThrowsError(try Email("the-local-part-is-invalid-if-it-is-longer-than-sixty-four-characters@sld.net"))
        XCTAssertThrowsError(try Email("the-total-length@of-an-entire-address.cannot-be-longer-than-two-hundred-and-fifty-four-characters.and-this-address-is-255-characters-exactly.so-it-should-be-invalid.and-im-going-to-add-some-more-words-here.to-increase-the-lenght-blah-blah-blah-blah-bl.org"))
        XCTAssertThrowsError(try Email("two..consecutive-dots@sld.com"))
        XCTAssertThrowsError(try Email("unbracketed-IP@127.0.0.1"))

        // examples of real (invalid) input from real users.
        XCTAssertThrowsError(try Email("No longer available."))
        XCTAssertThrowsError(try Email("Moved."))

        XCTAssertThrowsError(try DotAtom.parser().parse("two..consecutive-dots"))
    }
}

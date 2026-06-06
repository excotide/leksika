<?php

namespace Tests\Unit;

use App\Support\DocumentTitleFormatter;
use PHPUnit\Framework\TestCase;

class DocumentTitleFormatterTest extends TestCase
{
    public function test_it_cleans_file_extension_symbols_long_codes_and_title_case(): void
    {
        $title = DocumentTitleFormatter::format(
            '7519-ARTICLE+TEXT_29793-1-10-20231231.pdf'
        );

        $this->assertSame('Article Text', $title);
    }

    public function test_it_returns_fallback_when_title_has_no_words(): void
    {
        $this->assertSame('Tanpa Judul', DocumentTitleFormatter::format('---123456.pdf'));
    }
}

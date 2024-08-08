#!/usr/bin/perl -w

use Modern::Perl '2017';
use utf8;

use ProductOpener::Test qw/compare_to_expected_results init_expected_results/;
use ProductOpener::Routing qw/analyze_request load_routes/;
use ProductOpener::Lang qw/$lc /;

use Test2::V0;
use Mock::Quick;
use Data::Dumper;
$Data::Dumper::Terse = 1;
use Log::Any::Adapter 'TAP';

my ($test_id, $test_dir, $expected_result_dir, $update_expected_results) = (init_expected_results(__FILE__));
# TODO: add tests for all routes
load_routes();

my @tests = (
	{
		id => "api-v0-attribute-groups",
		desc => "API to get attribute groups",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'api/v0/attribute_groups',
			no_index => '0',
			is_crawl_bot => '1'
		},
	},
	{
		id => 'invalid-last-url-component',
		desc => "Invalid URL with last component which is not a facet or a page number",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'category/breads/no-nutrition-data',
			no_index => '0',
			is_crawl_bot => '0'
		},
	},
	{
		id => 'facet-url',
		desc => "Facet URL",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'category/breads',
			no_index => '0',
			is_crawl_bot => '1'
		},
	},
	{
		id => 'facet-url-with-page-number',
		desc => "Facet URL with a page number",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'category/breads/4',
			no_index => '0',
			is_crawl_bot => '1'
		},
	},
	{
		id => 'facet-url-with-synonym-and-page-number',
		desc => "Facet URL with a facet synonym and a page number",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'category/bread/4',
			no_index => '0',
			is_crawl_bot => '0'
		},
	},
	{
		id => 'api-v3-product-code',
		desc => "API v3 URL with product code",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'api/v3/product/03564703999971',
			no_index => '0',
			is_crawl_bot => '0'
		},
	},
	{
		id => 'api-v3-product-gs1-data-uri',
		desc => "API v3 URL with product GS1 Data URI",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string =>
				'api/v3/product/https%3A%2F%2Fid.gs1.org%2F01%2F03564703999971%2F10%2FABC%2F21%2F123456%3F17%3D211200',
			no_index => '0',
			is_crawl_bot => '0'
		},
	},
	{
		id => 'facet-url-group-by',
		desc => "Facet URL with a group-by",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'category/breads/ingredients',
			no_index => '0',
			is_crawl_bot => '1'
		},
	},
	{
		id => 'facet-url-group-by-in-english',
		desc => "Facet URL with a group-by in English",
		lc => "en",
		input_request => {
			cc => "world",
			lc => "es",
			original_query_string => 'category/breads/ingredients',
			no_index => '0',
			is_crawl_bot => '1'
		},
	},
	{
		id => 'geoip-get-country-from-ipv4-us',
		desc => 'geoip get country from ipv4 us',
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'api/v3/geopip/12.45.23.45',
			no_index => '0',
			is_crawl_bot => '0',
		}
	},
	{
		id => 'geoip-get-country-from-ipv6-fr',
		desc => 'geoip get country from ipv6 fr',
		lc => "en",
		input_request => {
			cc => "world",
			lc => "en",
			original_query_string => 'api/v3/geopip/2001:ac8:25:3b::e01d',
			no_index => '0',
			is_crawl_bot => '0',

		},
	},
);

foreach my $test_ref (@tests) {

	# Set $lc global because currently analyze_request uses the global $lc
	$lc = $test_ref->{input_request}{lc};
	analyze_request($test_ref->{input_request});
	compare_to_expected_results(
		$test_ref->{input_request},
		"$expected_result_dir/$test_ref->{id}.json",
		$update_expected_results, $test_ref
	);
}

done_testing();

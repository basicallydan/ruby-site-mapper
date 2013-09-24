$(document).ready(function () {
	$('.page').each(function () {
		var links = $(this).find('.links-list');
		var linksHeader = $(this).find('.links-header');
		var assets = $(this).find('.assets-list');
		var assetsHeader = $(this).find('.assets-header');

		linksHeader.click(function (e) {
			links.toggleClass('hidden');
		});
		assetsHeader.click(function (e) {
			assets.toggleClass('hidden');
		});
	});
});
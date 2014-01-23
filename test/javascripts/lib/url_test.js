module("Discourse.URL");

test("isInternal with a HTTP url", function() {
  this.stub(Discourse.URL, "origin").returns("http://eviltrout.com");

  ok(!Discourse.URL.isInternal(null), "a blank URL is not internal");
  ok(Discourse.URL.isInternal("/test"), "relative URLs are internal");
  ok(Discourse.URL.isInternal("http://eviltrout.com/tophat"), "a url on the same host is internal");
  ok(Discourse.URL.isInternal("https://eviltrout.com/moustache"), "a url on a HTTPS of the same host is internal");
  ok(!Discourse.URL.isInternal("http://twitter.com"), "a different host is not internal");
});

test("isInternal with a HTTPS url", function() {
  this.stub(Discourse.URL, "origin").returns("https://eviltrout.com");
  ok(Discourse.URL.isInternal("http://eviltrout.com/monocle"), "HTTPS urls match HTTP urls");
});

test("navigatedToHome", function() {
  var fakeDiscoveryController = { send: function() { return true; } };
  var mock = sinon.mock(fakeDiscoveryController);
  this.stub(Discourse.URL, "controllerFor").returns(fakeDiscoveryController);

  mock.expects("send").withArgs('refresh').twice();
  ok(Discourse.URL.navigatedToHome("/", "/"));

  var homepage = "/" + Discourse.Utilities.defaultHomepage();
  ok(Discourse.URL.navigatedToHome(homepage, "/"));

  ok(!Discourse.URL.navigatedToHome("/old", "/new"));

  // make sure we called the .refresh() method
  mock.verify();
});

import { acceptance } from "helpers/qunit-helpers";
acceptance("User Directory");

test("Visit Page", function() {
  visit("/users");
  andThen(() => {
    ok(exists('.directory table tr'), "has a list of users");
  });
});

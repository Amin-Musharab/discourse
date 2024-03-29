import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { click, render } from "@ember/test-helpers";
import { exists, query } from "discourse/tests/helpers/qunit-helpers";
import hbs from "htmlbars-inline-precompile";
import { module, test } from "qunit";

module("Discourse Chat | Component | chat-message-reaction", function (hooks) {
  setupRenderingTest(hooks);

  test("accepts arbitrary class property", async function (assert) {
    await render(hbs`
      <ChatMessageReaction @reaction={{hash emoji="heart"}} @class="foo" />
    `);

    assert.true(exists(".chat-message-reaction.foo"));
  });

  test("adds reacted class when user reacted", async function (assert) {
    await render(hbs`
      <ChatMessageReaction @reaction={{hash emoji="heart" reacted=true}} />
    `);

    assert.true(exists(".chat-message-reaction.reacted"));
  });

  test("adds reaction name as class", async function (assert) {
    await render(hbs`<ChatMessageReaction @reaction={{hash emoji="heart"}} />`);

    assert.true(exists(`.chat-message-reaction[data-emoji-name="heart"]`));
  });

  test("adds show class when count is positive", async function (assert) {
    this.set("count", 0);

    await render(hbs`
      <ChatMessageReaction @reaction={{hash emoji="heart" count=this.count}} />
    `);

    assert.false(exists(".chat-message-reaction.show"));

    this.set("count", 1);
    assert.true(exists(".chat-message-reaction.show"));
  });

  test("title/alt attributes", async function (assert) {
    await render(hbs`<ChatMessageReaction @reaction={{hash emoji="heart"}} />`);

    assert.strictEqual(query(".chat-message-reaction").title, ":heart:");
    assert.strictEqual(query(".chat-message-reaction img").alt, ":heart:");
  });

  test("count of reactions", async function (assert) {
    this.set("count", 0);

    await render(hbs`
      <ChatMessageReaction @reaction={{hash emoji="heart" count=this.count}} />
    `);

    assert.false(exists(".chat-message-reaction .count"));

    this.set("count", 2);
    assert.strictEqual(query(".chat-message-reaction .count").innerText, "2");
  });

  test("reaction’s image", async function (assert) {
    await render(hbs`<ChatMessageReaction @reaction={{hash emoji="heart"}} />`);

    const src = query(".chat-message-reaction img").src;
    assert.true(/heart\.png/.test(src));
  });

  test("click action", async function (assert) {
    this.set("count", 0);
    this.set("react", () => {
      this.set("count", 1);
    });

    await render(hbs`
      <ChatMessageReaction class="show" @reaction={{hash emoji="heart" count=this.count}} @react={{this.react}} />
    `);

    assert.false(exists(".chat-message-reaction .count"));

    await click(".chat-message-reaction");
    assert.strictEqual(query(".chat-message-reaction .count").innerText, "1");
  });
});

require 'spec_helper'
require_dependency 'plugin/instance'

describe Plugin::Instance do

  after do
    DiscoursePluginRegistry.javascripts.clear
    DiscoursePluginRegistry.admin_javascripts.clear
    DiscoursePluginRegistry.server_side_javascripts.clear
    DiscoursePluginRegistry.stylesheets.clear
    DiscoursePluginRegistry.mobile_stylesheets.clear
  end

  context "find_all" do
    it "can find plugins correctly" do
      plugins = Plugin::Instance.find_all("#{Rails.root}/spec/fixtures/plugins")
      plugins.count.should == 1
      plugin = plugins[0]

      plugin.name.should == "plugin-name"
      plugin.path.should == "#{Rails.root}/spec/fixtures/plugins/my_plugin/plugin.rb"
    end

    it "does not blow up on missing directory" do
      plugins = Plugin::Instance.find_all("#{Rails.root}/frank_zappa")
      plugins.count.should == 0
    end
  end

  context "register asset" do
    it "does register css properly" do
      plugin = Plugin::Instance.new nil, "/tmp/test.rb"
      plugin.register_asset("test.css")
      plugin.assets.count.should == 1
      plugin.register_asset("test2.css")
      plugin.assets.count.should == 2

    end
    it "does register mobile css properly" do
      plugin = Plugin::Instance.new nil, "/tmp/test.rb"
      plugin.register_asset("test.css", :mobile)
      plugin.assets.count.should == 0
      plugin.mobile_styles.count.should == 1
    end
    it "does register admin javascript properly" do
      plugin = Plugin::Instance.new nil, "/tmp/test.rb"
      plugin.register_asset("my_admin.js", :admin)
      plugin.assets.count.should == 0
      plugin.admin_javascripts.count.should == 1
    end
    it "does register server side javascript properly" do
      plugin = Plugin::Instance.new nil, "/tmp/test.rb"
      plugin.register_asset("my_admin.js", :server_side)
      # server side is both in assets and in server_side
      plugin.assets.count.should == 1
      plugin.server_side_javascripts.count.should == 1
    end
  end


  context "activate!" do
    it "can activate plugins correctly" do
      plugin = Plugin::Instance.new
      plugin.path = "#{Rails.root}/spec/fixtures/plugins/my_plugin/plugin.rb"
      junk_file = "#{plugin.auto_generated_path}/junk"

      plugin.ensure_directory(junk_file)
      File.open("#{plugin.auto_generated_path}/junk", "w") {|f| f.write("junk")}
      plugin.activate!

      plugin.auth_providers.count.should == 1
      auth_provider = plugin.auth_providers[0]
      auth_provider.authenticator.name.should == 'ubuntu'

      # calls ensure_assets! make sure they are there
      plugin.assets.count.should == 1
      plugin.assets.each do |a|
        File.exists?(a).should be_true
      end

      # ensure it cleans up all crap in autogenerated directory
      File.exists?(junk_file).should be_false
    end

    it "finds all the custom assets" do
      plugin = Plugin::Instance.new
      plugin.path = "#{Rails.root}/spec/fixtures/plugins/my_plugin/plugin.rb"
      # two styles
      plugin.register_asset("test.css")
      plugin.register_asset("test2.scss")
      # one javascript
      plugin.register_asset("code.js")
      # one mobile
      plugin.register_asset("test.css", :mobile)
      # a server side
      plugin.register_asset("server_side.js", :server_side)
      # and two admin
      plugin.register_asset("my_admin.js", :admin)
      plugin.register_asset("my_admin2.js", :admin)

      plugin.activate!

      DiscoursePluginRegistry.javascripts.count.should == 3
      DiscoursePluginRegistry.admin_javascripts.count.should == 2
      DiscoursePluginRegistry.server_side_javascripts.count.should == 1
      DiscoursePluginRegistry.stylesheets.count.should == 2
      DiscoursePluginRegistry.mobile_stylesheets.count.should == 1
    end
  end

end

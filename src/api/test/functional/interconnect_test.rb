require File.dirname(__FILE__) + '/../test_helper'
require 'source_controller'

class InterConnectTests < ActionController::IntegrationTest 

  fixtures :all
   
  def test_anonymous_access
    ActionController::IntegrationTest::reset_auth 
    get "/public/lastevents"
    assert_response :success

    # direct access
    get "/public/source/BaseDistro"
    assert_response :success
    get "/public/source/BaseDistro/_meta"
    assert_response :success
    get "/public/source/BaseDistro/_config"
    assert_response :success
    get "/public/source/BaseDistro/_pubkey"
    assert_response :success
    get "/public/source/BaseDistro/pack1"
    assert_response :success
    get "/public/source/BaseDistro/pack1?view=cpio"
    assert_response :success
    get "/public/source/BaseDistro/pack1/_meta"
    assert_response :success
    get "/public/source/BaseDistro/pack1/my_file"
    assert_response :success

    # direct access to remote instance
    get "/public/source/RemoteInstance:BaseDistro"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/_meta"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/_config"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/_pubkey"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/pack1"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/pack1/_meta"
    assert_response :success
    get "/public/source/RemoteInstance:BaseDistro/pack1/my_file"
    assert_response :success

    # binary access
    get "/public/build/home:Iggy/10.2/i586/_repository?view=cache"
    assert_response :success
    get "/public/build/home:Iggy/10.2/i586/_repository?view=solvstate"
    assert_response :success
    get "/public/build/home:Iggy/10.2/i586/_repository?view=binaryversions"
    assert_response :success
    get "/public/build/home:Iggy/10.2/i586/pack1"
    assert_response :success
    get "/public/build/home:Iggy/10.2/i586/pack1?view=cpio"
    assert_response :success
    get "/public/build/home:Iggy/10.2/i586/pack1?view=binaryversions"
    assert_response :success

    # access to local project with project link to remote
    get "/public/source/UseRemoteInstance"
    assert_response :success
    get "/public/source/UseRemoteInstance/_meta"
    assert_response :success
    get "/public/source/UseRemoteInstance/pack1"
    assert_response :success
    get "/public/source/UseRemoteInstance/pack1/_meta"
    assert_response :success
    get "/public/source/UseRemoteInstance/pack1/my_file"
    assert_response :success
    get "/public/source/UseRemoteInstance/NotExisting"
    assert_response 404
    get "/public/source/UseRemoteInstance/NotExisting/_meta"
    assert_response 404
    get "/public/source/UseRemoteInstance/NotExisting/my_file"
    assert_response 404
  end

  def test_read_and_command_tests
    prepare_request_with_user "tom", "thunder"
    get "/source"
    assert_response :success

    # direct access to remote instance
    get "/source/RemoteInstance:BaseDistro"
    assert_response :success
    get "/source/RemoteInstance:BaseDistro/_meta"
    assert_response :success
    get "/source/RemoteInstance:BaseDistro/_pubkey"
    assert_response :success
    get "/source/RemoteInstance:BaseDistro/pack1"
    assert_response :success
    get "/source/RemoteInstance:BaseDistro/pack1/_meta"
    assert_response :success
    get "/source/RemoteInstance:BaseDistro/pack1/my_file"
    assert_response :success
    if $ENABLE_BROKEN_TEST
    post "/source/RemoteInstance:BaseDistro/pack1", :cmd => "showlinked"
    puts @response.body
    assert_response :success
    post "/source/RemoteInstance:BaseDistro/pack1", :cmd => "branch"
    assert_response :success
    end
    # test binary operations
    prepare_request_with_user "king", "sunflower"
    post "/build/RemoteInstance:BaseDistro", :cmd => "wipe", :package => "pack1"
    assert_response 404
    post "/build/RemoteInstance:BaseDistro", :cmd => "rebuild", :package => "pack1"
    assert_response 404
    post "/build/RemoteInstance:BaseDistro", :cmd => "wipe"
    assert_response 404
    post "/build/RemoteInstance:BaseDistro", :cmd => "rebuild"
    assert_response 404

    # direct access to remote instance, not existing project/package
    prepare_request_with_user "tom", "thunder"
    get "/source/RemoteInstance:NotExisting/_meta"
    assert_response 404
    get "/source/RemoteInstance:NotExisting/pack1"
    assert_response 404
    get "/source/RemoteInstance:NotExisting/pack1/_meta"
    assert_response 404
    get "/source/RemoteInstance:NotExisting/pack1/my_file"
    assert_response 404
    get "/source/RemoteInstance:BaseDistro/NotExisting"
    assert_response 404
    get "/source/RemoteInstance:BaseDistro/NotExisting/_meta"
    assert_response 404
    get "/source/RemoteInstance:BaseDistro/NotExisting/my_file"
    assert_response 404
    get "/source/RemoteInstance:kde4/_pubkey"
    assert_response 404
    assert_match(/no pubkey available/, @response.body)

    # access to local project with project link to remote
    get "/source/UseRemoteInstance"
    assert_response :success
    get "/source/UseRemoteInstance/_meta"
    assert_response :success
    get "/source/UseRemoteInstance/pack1"
    assert_response :success
    get "/source/UseRemoteInstance/pack1/_meta"
    assert_response :success
    get "/source/UseRemoteInstance/pack1/my_file"
    assert_response :success
if $ENABLE_BROKEN_TEST
    post "/source/UseRemoteInstance/pack1", :cmd => "showlinked"
    puts @response.body
    assert_response :success
    post "/source/UseRemoteInstance/pack1", :cmd => "branch"
    assert_response :success
end
    get "/source/UseRemoteInstance/NotExisting"
    assert_response 404
    get "/source/UseRemoteInstance/NotExisting/_meta"
    assert_response 404
    get "/source/UseRemoteInstance/NotExisting/my_file"
    assert_response 404
    # test binary operations
    prepare_request_with_user "king", "sunflower"
    post "/build/UseRemoteInstance", :cmd => "wipe", :package => "pack1"
    assert_response :success
    post "/build/UseRemoteInstance", :cmd => "rebuild", :package => "pack1"
    assert_response :success
    post "/build/UseRemoteInstance", :cmd => "wipe"
    assert_response :success
    post "/build/UseRemoteInstance", :cmd => "rebuild"
    assert_response :success

    # access via a local package linking to a remote package
    prepare_request_with_user "tom", "thunder"
    get "/source/LocalProject/remotepackage"
    assert_response :success
    ret = ActiveXML::XMLNode.new @response.body
    xsrcmd5 = ret.linkinfo.xsrcmd5
    assert_not_nil xsrcmd5
    post "/source/LocalProject/remotepackage", :cmd => "showlinked"
    assert_response :success
    get "/source/LocalProject/remotepackage/_meta"
    assert_response :success
    get "/source/LocalProject/remotepackage/my_file"
    assert_response 404
    get "/source/LocalProject/remotepackage/_link"
    assert_response :success
    ret = ActiveXML::XMLNode.new @response.body
    assert_equal ret.project, "RemoteInstance:BaseDistro"
    assert_equal ret.package, "pack1"
    get "/source/LocalProject/remotepackage/my_file?rev=#{xsrcmd5}"
    assert_response :success
    post "/source/LocalProject/remotepackage", :cmd => "branch"
    assert_response :success
    get "/source/LocalProject/remotepackage/_link?rev=#{xsrcmd5}"
    assert_response 404
    get "/source/LocalProject/remotepackage/not_existing"
    assert_response 404
    # test binary operations
    prepare_request_with_user "king", "sunflower"
    post "/build/LocalProject", :cmd => "wipe", :package => "remotepackage"
    assert_response :success
    post "/build/LocalProject", :cmd => "rebuild", :package => "remotepackage"
    assert_response :success
    post "/build/LocalProject", :cmd => "wipe"
    assert_response :success
    post "/build/LocalProject", :cmd => "rebuild"
    assert_response :success

  end

  def test_copy_and_diff_package
    # do copy commands twice to test it with existing target and without
    prepare_request_with_user "tom", "thunder"
    post "/source/LocalProject/temporary", :cmd => :copy, :oproject => "LocalProject", :opackage => "remotepackage"
    assert_response :success
    post "/source/LocalProject/temporary", :cmd => :copy, :oproject => "LocalProject", :opackage => "remotepackage"
    assert_response :success
    delete "/source/LocalProject/temporary"
    assert_response :success
    post "/source/LocalProject/temporary", :cmd => :copy, :oproject => "UseRemoteInstance", :opackage => "pack1"
    assert_response :success
    post "/source/LocalProject/temporary", :cmd => :copy, :oproject => "RemoteInstance:BaseDistro", :opackage => "pack1"
    assert_response :success

    post "/source/LocalProject/temporary", :cmd => :diff, :oproject => "LocalProject", :opackage => "remotepackage"
    assert_response :success
    post "/source/LocalProject/temporary", :cmd => :diff, :oproject => "UseRemoteInstance", :opackage => "pack1"
    assert_response :success
  end

  def test_diff_package
    prepare_request_with_user "tom", "thunder"

# FIXME: not supported in api atm
#    post "/source/RemoteInstance:BaseDistro/pack1", :cmd => :branch, :target_project => "LocalProject", :target_package => "branchedpackage"
#    assert_response :success

    Suse::Backend.put( '/source/LocalProject/newpackage/_meta', DbPackage.find_by_project_and_name("LocalProject", "newpackage").to_axml)
    Suse::Backend.put( '/source/LocalProject/newpackage/new_file', "adding stuff")
    post "/source/LocalProject/newpackage", :cmd => :diff, :oproject => "RemoteInstance:BaseDistro", :opackage => "pack1"
    assert_response :success
  end

end

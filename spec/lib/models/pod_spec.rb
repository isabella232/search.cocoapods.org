require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../lib/models/pod', __FILE__)

describe Pod do
  describe 'AFNetworking' do
    
    def specification
      Hashie::Mash.new(
        "name"=>"AFNetworking",
        "version"=>"2.3.1",
        "license"=>"MIT",
        "summary"=>"A delightful iOS and OS X networking framework.",
        "homepage"=>"https://github.com/AFNetworking/AFNetworking",
        "social_media_url"=>"https://twitter.com/AFNetworking",
        "authors"=>{"Mattt Thompson"=>"m@mattt.me"},
        "source"=>{
          "git"=>"https://github.com/AFNetworking/AFNetworking.git",
          "tag"=>"2.3.1",
          "submodules"=>true},
          "requires_arc"=>true,
          "platforms"=>{
            "ios"=>"6.0",
            "osx"=>"10.8"
          },
          "public_header_files"=>"AFNetworking/*.h",
          "source_files"=>"AFNetworking/AFNetworking.h",
          "subspecs"=>[
            {
              "name"=>"Serialization",
              "source_files"=>"AFNetworking/AFURL{Request,Response}Serialization.{h,m}",
              "ios"=>{
                "frameworks"=>[
                  "MobileCoreServices",
                  "CoreGraphics"
                ]
              },
              "osx"=>{
                "frameworks"=>"CoreServices"
              }
            },
            {
              "name"=>"Security",
              "source_files"=>"AFNetworking/AFSecurityPolicy.{h,m}",
              "frameworks"=>"Security"
            }, {
              "name"=>"Reachability",
              "source_files"=>"AFNetworking/AFNetworkReachabilityManager.{h,m}",
              "frameworks"=>"SystemConfiguration"
            },
            {
              "name"=>"NSURLConnection",
              "dependencies"=>{
                "AFNetworking/Serialization"=>[],
                "AFNetworking/Reachability"=>[],
                "AFNetworking/Security"=>[]
              },
              "source_files"=>[
                "AFNetworking/AFURLConnectionOperation.{h,m}",
                "AFNetworking/AFHTTPRequestOperation.{h,m}",
                "AFNetworking/AFHTTPRequestOperationManager.{h,m}"
              ]
            },
            {
              "name"=>"NSURLSession",
              "dependencies"=>{
                "AFNetworking/Serialization"=>[],
                "AFNetworking/Reachability"=>[],
                "AFNetworking/Security"=>[]
              },
              "source_files"=>[
                "AFNetworking/AFURLSessionManager.{h,m}",
                "AFNetworking/AFHTTPSessionManager.{h,m}"
              ]
            },
            {
              "name"=>"UIKit",
              "platforms"=>{
                "ios"=>"6.0"
              },
              "dependencies"=>{
                "AFNetworking/NSURLConnection"=>[],
                "AFNetworking/NSURLSession"=>[]
              },
              "ios"=>{
                "public_header_files"=>"UIKit+AFNetworking/*.h",
                "source_files"=>"UIKit+AFNetworking"
              },
              "osx"=>{
                "source_files"=>""
              }
            }
          ]
        )
    end
    
    def pod
      Pod.new(specification)
    end
  
    ok { pod.name.should == 'AFNetworking' }
    ok { pod.split_name.should == ['afnetworking', 'af', 'networking'] }
    ok { pod.split_name_for_automatic_splitting.should == ['networking'] }
    
  end
end

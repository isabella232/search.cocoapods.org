# coding: utf-8
# frozen_string_literal: true
#
require File.expand_path '../../spec_helper', __FILE__
require 'picky-client/spec'

# Spec for the flat ids result list API.
#
# Uses the fixed set of pods from the ./data directory.
#
describe 'Flat Ids Integration Tests' do

  # In these tests we are abusing the Picky client a little.
  #

  def pod_hash
    @pod_hash ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.hash.json'
  end

  def first_three_names_for_search(query, options = {})
    pods.search(query, options).first(3)
  end

  # Testing the format.
  #
  ok { pod_hash.search('on:osx afnetworking', sort: 'name').first.should == {:id=>"AFNetworking", :platforms=>["ios", "osx", "watchos", "tvos"], :version=>"3.1.0", :summary=>"A delightful iOS and OS X networking framework.", :authors=>{:"Mattt Thompson"=>"m@mattt.me"}, :link=>"https://github.com/AFNetworking/AFNetworking", :source=>{:git=>"https://github.com/AFNetworking/AFNetworking.git", :tag=>"3.1.0", :submodules=>true}, :tags=>["network"], :cocoadocs=>true} }

  def pods
    @pods ||= Picky::TestClient.new CocoapodSearch, path: '/api/v1/pods.flat.ids.json'
  end

  # Testing the format.
  #
  ok { first_three_names_for_search('on:osx afnetworking', sort: 'name').should == ["AFNetworking", "YTKNetwork"] }

  # Error cases.
  #
  it "does not raise an error when searching for 'pod'" do
    should.not.raise { pods.search 'pod' }
  end

  # This is how results should look - a flat list of ids.
  #
  ok { first_three_names_for_search('on:ios 1.0.0', ids: 200, sort: 'name').should == ["Appirater", "Aspects", "Atlas"] }

  # Testing a count of results.
  #
  ok { pods.search('on:ios 1.0.0', ids: 10_000).size.should == 63 }

  # Speed.
  #
  it 'is fast enough' do
    require 'benchmark'
    Benchmark.realtime { pods.search('on:osx k* a') }.should < 0.02 # seconds
  end

  # Multiple results and uniqueness.
  #
  ok { first_three_names_for_search('afnetworking', sort: 'name').should == ["AFNetworking", "YTKNetwork", "Nimbus"] }

  # Similarity on author.
  #
  # Has been removed.
  # ok { first_three_names_for_search('on:ios mettt~', sort: 'name').should == %w(AFIncrementalStore AFNetworking CargoBay) }

  # Partial version search.
  #
  expected_results_pre_1_0_0 = %w(AFNetworking YTKNetwork)
  ok { first_three_names_for_search('on:osx afnetworking 1', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { first_three_names_for_search('on:osx afnetworking 1.', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { first_three_names_for_search('on:osx afnetworking 1.0', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { first_three_names_for_search('on:osx afnetworking 1.0.', sort: 'name').should == expected_results_pre_1_0_0 }
  ok { first_three_names_for_search('on:osx afnetworking 1.0.0', sort: 'name').should == ["YTKNetwork"] } # TODO Why?

  # Platform constrained search (platforms are AND-ed).
  #
  expected = %w(AFNetworking FormatterKit)
  ok { first_three_names_for_search('on:osx mattt', sort: 'name').should == expected }
  ok { first_three_names_for_search('on:ios mattt', sort: 'name').should == ["AFNetworking", "FormatterKit", "TTTAttributedLabel"] }
  ok { first_three_names_for_search('on:osx on:ios mattt', sort: 'name').should == expected }

  # Partial.
  #
  # Platform is only found when fully mentioned (i.e. no partial).
  #
  ok { pods.search('platform:osx', ids: 10_000).size.should == 87 }
  ok { pods.search('platform:os').size.should == 0 }
  ok { pods.search('platform:o').size.should == 0 }

  # Qualifiers.
  #
  ok { first_three_names_for_search('name:afnetworking mattt thompson').should == ['AFNetworking'] }
  ok { first_three_names_for_search('pod:afnetworking mattt thompson').should == ['AFNetworking'] }

  expected = %w(AFNetworking)
  ok { first_three_names_for_search('afnetworking author:mattt author:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('afnetworking authors:mattt authors:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('afnetworking written:mattt written:thompson', sort: 'name').should == expected }
  ok { first_three_names_for_search('afnetworking writer:mattt writer:thompson', sort: 'name').should == expected }
  # ok { pods.search('kiwi by:allen by:ding').should == ['Kiwi'] } # by is removed by stopwords.

  expected_dependencies = %w(Nimbus YTKNetwork)
  ok { first_three_names_for_search('dependency:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('dependencies:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('depends:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('using:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('uses:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('use:AFNetworking', sort: 'name').should == expected_dependencies }
  ok { first_three_names_for_search('needs:AFNetworking', sort: 'name').should == expected_dependencies }

  ok { pods.search('platform:osx', ids: 10_000).size.should == 87 }
  ok { pods.search('on:osx', ids: 10_000).size.should == 87 }

  # Stemming.
  #
  expected = ["AFNetworking", "Alamofire", "CocoaAsyncSocket"]
  ok { first_three_names_for_search('networking', sort: 'name').should == expected }
  ok { first_three_names_for_search('summary:network', sort: 'name').should == expected }
  ok { first_three_names_for_search('summary:networking', sort: 'name').should == expected }

  # No single characters indexed.
  #
  ok { pods.search('on:ios "a"').should == [] }

end

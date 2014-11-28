Pod::Spec.new do |s|
  s.name         = 'Expecta+Snapshots'
  s.version      = '1.3.0'
  s.summary      = 'Expecta matchers for taking view snapshots with FBSnapshotTestCase.'
  s.description  = "Use ios-snapshot-test-case's FBSnapshotTest with Expecta matchers for readability."
  s.homepage     = 'https://github.com/dblock/ios-snapshot-test-case-expecta'
  s.license      = 'MIT'
  s.author       = { 'Daniel Doubrovkine' => "dblock@dblock.org", "orta" => "orta.therox@gmail.com" }
  s.source       = { :git => 'https://github.com/dblock/ios-snapshot-test-case-expecta.git', :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'EXPMatchers+FBSnapshotTest.{h,m}'
  s.frameworks   = 'Foundation', 'XCTest'
  s.dependencies = ['Expecta', 'FBSnapshotTestCase']
end

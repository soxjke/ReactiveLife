source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!
    
def pods
	pod 'ReactiveCocoa', '5.0.1'
	# pod 'ReactiveObjC'	
	pod 'SnapKit', '3.2.0'
    pod 'Alamofire'
end

app_targets = ['ReactiveSearch', 'ReactiveNetwork', 'CompositeTableView']

app_targets.each { |targetName|
    target targetName do
        pods
    end
}

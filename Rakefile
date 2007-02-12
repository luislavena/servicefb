#--
# Copyright (c) 2006-2007 Luis Lavena, Multimedia systems
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rake/packagetask'
require 'rakehelp/freebasic'

PRODUCT_NAME = 'ServiceFB'
PRODUCT_VERSION = '0.3.0'

# Package ServiceFB for source distribution
Rake::PackageTask.new(PRODUCT_NAME.downcase, PRODUCT_VERSION) do |p|
  p.need_zip = true
  p.package_files.include 'README', 'CHANGELOG', 'TODO', 'MIT-LICENSE', 'Rakefile', 
                          'docs/**/*', 'lib/**/*.{bas,bi,rc}', 'samples/*.{bas,bi,rc}', 'rakehelp/*.rb'
end

# global options shared by all the project in this Rakefile
OPTIONS = { :debug => false, :profile => false, :errorchecking => :ex, :mt => true }

OPTIONS[:debug] = true if ENV['DEBUG']
OPTIONS[:profile] = true if ENV['PROFILE']
OPTIONS[:errorchecking] = :exx if ENV['EXX']

# ServiceFB namespace (lib)
namespace :lib do
  project_task 'servicefb' do
    lib         'ServiceFB'
    build_to    'lib'

    define      'SERVICEFB_DEBUG_LOG' if ENV['DEBUG_LIB']
    source      'lib/ServiceFB/ServiceFB.bas'
    
    option      OPTIONS
  end
  
  project_task 'servicefb_utils' do
    lib         'ServiceFB_Utils'
    build_to    'lib'

    define      'SERVICEFB_DEBUG_LOG' if ENV['DEBUG_LIB']
    source      'lib/ServiceFB/ServiceFB_Utils.bas'
    
    option      OPTIONS
  end
end
#add lib namespace to global tasks
include_projects_of :lib

# Samples namespace (samples)
namespace :samples do
  project_task 'basic_service' do
    executable  'basic_service'
    
    build_to    '.'

    main        "samples/basic_service.bas"

    lib_path    'lib'
    library     'ServiceFB'
    library     'user32', 'advapi32'
    
    option      OPTIONS
  end
  project_task 'adv_service' do
    executable  'adv_service'
    
    build_to    '.'

    main        "samples/adv_service.bas"

    lib_path    'lib'
    library     'ServiceFB', 'ServiceFB_Utils'
    # using ServiceFB_Utils library requires also psapi library
    library     'user32', 'advapi32', 'psapi'
    
    option      OPTIONS
  end
  project_task 'complex_service' do
    executable  'complex_service'
    
    build_to    '.'

    main        "samples/complex_service.bas"

    lib_path    'lib'
    library     'ServiceFB'
    library     'ServiceFB_Utils'
    # using ServiceFB_Utils library requires also psapi library
    library     'user32', 'advapi32', 'psapi'
    
    option      OPTIONS
  end
end
include_projects_of :samples

#task :default => :build
'#--
'# Copyright (c) 2006-2007 Luis Lavena, Multimedia systems
'#
'# This source code is released under the MIT License.
'#
'# Permission is hereby granted, free of charge, to any person obtaining
'# a copy of this software and associated documentation files (the
'# "Software"), to deal in the Software without restriction, including
'# without limitation the rights to use, copy, modify, merge, publish,
'# distribute, sublicense, and/or sell copies of the Software, and to
'# permit persons to whom the Software is furnished to do so, subject to
'# the following conditions:
'#
'# The above copyright notice and this permission notice shall be
'# included in all copies or substantial portions of the Software.
'#
'# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
'# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
'# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
'# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
'# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'#++

'# Basic Service
'# this sample demostrate how to code a service-only program
'# it will start but will fail to fire back events (callbacks) due lack of
'# communication with SCM (Service Control Manager)
'#
'# written by Luis Lavena
'#
'# compile: fbc basic_service.bas ServiceFB.bas
'#
'# manually install this service using SC
'# 
'#   sc create basic_service binPath= C:\ServiceFB\basic_service.exe
'# 
'# to remove it:
'# 
'#  sc delete basic_service
'#

#include once "lib/ServiceFB/ServiceFB.bi"

'# you could use ServiceFB as lib!
'# compile it: fbc -lib ServiceFB.bas
'# and uncomment the following line
'#inclib "ServiceFB"

namespace basicserviceapp
    using fb.svc
    
    sub debug(byref message as string)
        dim handle as integer
        
        handle = freefile
        open EXEPATH + "\service.log" for append as #handle
        
        print #handle, message
        
        close #handle
    end sub
    
    '# actual service code, could be located in other module and then loaded using
    '# freebasic module/inclusion techniques
    namespace basic_service
        declare function onInit(byref as ServiceProcess) as integer
        declare sub onStart(byref as ServiceProcess)
        declare sub onStop(byref as ServiceProcess)
        declare sub onPause(byref as ServiceProcess)
        declare sub onContinue(byref as ServiceProcess)
        
        function onInit(byref self as ServiceProcess) as integer
          debug("onInit()")
          dim count as integer = 5
          
          '# If you plan do looooooong tasks during initialization of the service
          '# (like creating N child process that also take several seconds)
          '# I suggest periodically call self.StillAlive() method to report back
          '# to Service Manager (is like a heart-beat, only useful during initialization
          debug("delayed initialization of 5 seconds")
          do while (count > 0)
              sleep 1000
              count -= 1
              self.StillAlive()
          loop
          
          '# we are done, we must return TRUE (-1) to continue, or (0) to abort
          debug("done with onInit()")
          return (-1)
        end function
        
        sub onStart(byref self as ServiceProcess)
          debug("onStart()")
          
          '# Here is supposted we do our work, we will just wait for now
          '# We also should evaluate if the service is paused?
          '# Maybe using a condition?
          do while (self.state = Running) or (self.state = Paused)
              sleep 100
          loop
        
          debug("done with onStart()")
        end sub
        
        sub onStop(byref self as ServiceProcess)
          debug("onStop()")
        end sub
        
        sub onPause(byref self as ServiceProcess)
          debug("onPause()")
        end sub
        
        sub onContinue(byref self as ServiceProcess)
          debug("onContinue()")
        end sub
    end namespace
    
    '# sub main()
    '# removed the constructor due few problems with command function (and could 
    '# exist others too). This is because constructors are executed way before
    '# main() inside the rtlib, this is right? anyway won't get fixed, so:
    '# IS BAD CODING run your program from a constructor!
    sub main() 
        '# use debug imported from fb.svc
        debug("basicservice main()")
        
        '# create the new service and assing the name
        debug("create a new basic service")
        '# NOTE: we must be explicit when naming our service.
        '# running in single service mode with wrong naming isn't handled yet.
        dim BasicService as ServiceProcess = type<ServiceProcess>("basic_service")
        
        '# assign the actions to which this service will respond to
        debug("assign actions (callbacks)")
        with BasicService
            .onInit = @basic_service.onInit
            .onStart = @basic_service.onStart
            .onStop = @basic_service.onStop
            .onPause = @basic_service.onPause
            .onContinue = @basic_service.onContinue
        end with
        
        '# ok, start the service!
        debug("start the service")
        BasicService.Run()
        debug("done from basic_service.bas")
    end sub
    
end namespace


'# run your program
basicserviceapp.main()

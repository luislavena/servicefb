'#--
'# Copyright (c) 2006-2007 Luis Lavena, Multimedia systems
'#
'# This source code is released under the MIT License.
'# See MIT-LICENSE file for details
'#++

'# Advanced Service
'# this sample demostrate how to code a service program that also could be
'# run from command line (console mode) and provide management utilities
'# to install/uninstall or remove the service.
'# it requires the Utils module of ServiceFB, also linking to psapi
'#
'# written by Luis Lavena
'#
'# compile: fbc adv_service.bas ServiceFB.bas ServiceFB_Utils.bas
'#
'# manually install this service using SC
'# 
'#   sc create adv_service binPath= C:\ServiceFB\adv_service.exe
'# 
'# to remove it:
'# 
'#  sc delete adv_service
'#

'# the next define is used to automatically include the Utils definitions header
#define SERVICEFB_INCLUDE_UTILS
#include once "lib/ServiceFB/ServiceFB.bi"

'# in case of manual linking, you will require link this same to
'# user32, advapi32 and psapi

namespace advserviceapp
    using fb.svc
    using fb.svc.utils
    
    sub debug(byref message as string)
        dim handle as integer
        
        handle = freefile
        open EXEPATH + "\service.log" for append as #handle
        
        print #handle, message
        
        close #handle
    end sub
    
    '# actual service code, could be located in other module and then loaded using
    '# freebasic module/inclusion techniques
    namespace adv_service
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
        debug("advserviceapp main()")
        
        '# create the new service and assing the name
        debug("create a new service")
        '# NOTE: we must be explicit when naming our service.
        '# running in single service mode with wrong naming isn't handled yet.
        dim AdvService as ServiceProcess = type<ServiceProcess>("adv_service")
        dim Controller as ServiceController = type<ServiceController>("Adv Service", "v0.1", "(c) 2006 by Company")
        
        '# assign the actions to which this service will respond to
        debug("assign actions (callbacks)")
        with AdvService
            .description = "just a faked, empty, nt service."
            .onInit = @adv_service.onInit
            .onStart = @adv_service.onStart
            .onStop = @adv_service.onStop
            .onPause = @adv_service.onPause
            .onContinue = @adv_service.onContinue
        end with
        
        '# we should evaluate the start method here
        select case Controller.RunMode()
            case RunAsService:
                '# ok, start the service!
                debug("start the service")
                AdvService.Run()
                debug("done from singleservice.bas")
            
            case RunAsConsole:
                Controller.Console(AdvService)
                
            case RunAsManager:
                print "Manage calls go here"
                
            case RunAsUnknown:
                '# this is when you call it directly without params, from explorer or 
                '# from command line (cmd)
                print "Unknown state, what we should do?"
        end select
    end sub
end namespace

'# run your program
advserviceapp.main()

'#--
'# Copyright (c) 2006-2007 Luis Lavena, Multimedia systems
'#
'# This source code is released under the MIT License.
'# See MIT-LICENSE file for details
'#++

'# Complex Service
'# this sample demostrate how to pack 2 services in the same process, 
'# also sharing the process and reducing process overhead
'# it offer console mode and management tools too.
'# it requires the Utils module of ServiceFB, also linking to psapi
'#
'# written by Luis Lavena
'#
'# NOTE:
'# as example, the 2nd service don't offer Pause/Continue functionality,
'# ServiceFB will adapt automatically for this case.
'#
'# compile: fbc complex_service.bas ServiceFB.bas ServiceFB_Utils.bas
'#
'# manually install the services using SC:
'# 
'#   sc create multi_service_1 type= share binPath= C:\ServiceFB\complex_service.exe
'#   sc create multi_service_2 type= share binPath= C:\ServiceFB\complex_service.exe
'# 
'# to remove them:
'# 
'#  sc delete multi_service_1
'#  sc delete multi_service_2
'#
'# NOTE: the type= share part of SC command is important, without it both services
'# will run in their own processes instead.
'#

'# the next define is used to automatically include the Utils definitions header
#define SERVICEFB_INCLUDE_UTILS
#include once "lib/ServiceFB/ServiceFB.bi"

'# in case of manual linking, you will require link this same to
'# user32, advapi32 and psapi

namespace complexserviceapp
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
    '# multi_service_2
    namespace service_1
        const service_name as string = "multi_service_1"
        const service_desc as string = "service 1 description"
        
        declare function onInit(byref as ServiceProcess) as integer
        declare sub onStart(byref as ServiceProcess)
        declare sub onStop(byref as ServiceProcess)
        declare sub onPause(byref as ServiceProcess)
        declare sub onContinue(byref as ServiceProcess)
        
        function onInit(byref self as ServiceProcess) as integer
            debug(service_name + "." + "onInit()")
            dim count as integer = 15
            
            '# If you plan do looooooong tasks during initialization of the service
            '# (like creating N child process that also take several seconds)
            '# I suggest periodically call self.StillAlive() method to report back
            '# to Service Manager (is like a heart-beat, only useful during initialization
            debug("delayed initialization of 15 seconds")
            do while (count > 0)
                sleep 1000
                count -= 1
                self.StillAlive()
            loop
          
            '# we are done, we must return TRUE (-1) to continue, or (0) to abort
            debug("done with " + service_name + "." + "onInit()")
            return (-1)
        end function
        
        sub onStart(byref self as ServiceProcess)
            debug(service_name + "." + "onStart()")
            
            '# Here is supposted we do our work, we will just wait for now
            '# We also should evaluate if the service is paused?
            '# Maybe using a condition?
            do while (self.state = Running) or (self.state = Paused)
                sleep 100
            loop
            
            debug("done with " + service_name + "." + "onStart()")
        end sub
        
        sub onStop(byref self as ServiceProcess)
            debug(service_name + "." + "onStop()")
        end sub
        
        sub onPause(byref self as ServiceProcess)
            debug(service_name + "." + "onPause()")
        end sub
        
        sub onContinue(byref self as ServiceProcess)
            debug(service_name + "." + "onContinue()")
        end sub
    end namespace
    
    '# multi_service_2
    namespace service_2
        const service_name as string = "multi_service_2"
        const service_desc as string = "service 2 description"
        
        declare function onInit(byref as ServiceProcess) as integer
        declare sub onStart(byref as ServiceProcess)
        declare sub onStop(byref as ServiceProcess)
        
        function onInit(byref self as ServiceProcess) as integer
            debug(service_name + "." + "onInit()")
            dim count as integer = 3
            
            '# If you plan do looooooong tasks during initialization of the service
            '# (like creating N child process that also take several seconds)
            '# I suggest periodically call self.StillAlive() method to report back
            '# to Service Manager (is like a heart-beat, only useful during initialization
            debug("delayed initialization of 3 seconds")
            do while (count > 0)
                sleep 1000
                count -= 1
                self.StillAlive()
            loop
            
            '# we are done, we must return TRUE (-1) to continue, or (0) to abort
            debug("done with " + service_name + "." + "onInit()")
            return (-1)
        end function
        
        sub onStart(byref self as ServiceProcess)
            debug(service_name + "." + "onStart()")
            
            '# Here is supposted we do our work, we will just wait for now
            '# We also should evaluate if the service is paused?
            '# Maybe using a condition?
            do while (self.state = Running) or (self.state = Paused)
                sleep 100
            loop
            
            debug("done with " + service_name + "." + "onStart()")
        end sub
        
        sub onStop(byref self as ServiceProcess)
            debug(service_name + "." + "onStop()")
        end sub
        
    end namespace
    
    
    '# sub main()
    '# removed the constructor due few problems with command function (and could 
    '# exist others too). This is because constructors are executed way before
    '# main() inside the rtlib, this is right? anyway won't get fixed, so:
    '# IS BAD CODING run your program from a constructor!
    sub main()
        '# use debug imported from fb.svc
        debug("complexserviceapp main()")
        
        '# create the new service and assing the name
        debug("create 2 services")
        '# NOTE: we must be explicit when naming our service.
        dim Service1 as ServiceProcess = type<ServiceProcess>(service_1.service_name)
        dim Service2 as ServiceProcess = type<ServiceProcess>(service_2.service_name)
        dim Controller as ServiceController = type<ServiceController>("Complex Services", "v0.1", "(c) 2006 by Company")

        debug("create a Host for these services")
        dim Host as ServiceHost
        
        '# assign the actions to each service
        debug("assign actions (callbacks), service 1")
        with Service1
            .description = service_1.service_desc
            .onInit = @service_1.onInit
            .onStart = @service_1.onStart
            .onStop = @service_1.onStop
            .onPause = @service_1.onPause
            .onContinue = @service_1.onContinue
        end with
        
        debug("assign actions (callbacks), service 2")
        with Service2
            .description = service_2.service_desc
            .onInit = @service_2.onInit
            .onStart = @service_2.onStart
            .onStop = @service_2.onStop
        end with
        
        '# register these services with the host
        debug("registering service 1")
        Host.Add(Service1)
        
        debug("registering service 2")
        Host.Add(Service2)

        '# ok, start the services using the Host!
        '# we should evaluate the start method here
        select case Controller.RunMode()
            case RunAsService:
                '# ok, start the service!
                debug("start the services")
                Host.Run()
            
            case RunAsConsole:
                Controller.Console()
                
            case RunAsManager:
                print "Manage calls go here"
                
            case RunAsUnknown:
                '# this is when you call it directly without params, from explorer or 
                '# from command line (cmd)
                print "Unknown state, what we should do?"
        end select

        debug("done from multiservice.bas")
    end sub
end namespace


'# run your program
complexserviceapp.main()

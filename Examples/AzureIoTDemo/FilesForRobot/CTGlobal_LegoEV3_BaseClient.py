# https://azure.microsoft.com/en-us/documentation/articles/iot-hub-mqtt-support/
# http://stackoverflow.com/questions/35452072/python-mqtt-connection-to-azure-iot-hub/35473777
# https://azure.microsoft.com/en-us/documentation/samples/iot-hub-python-get-started/


# Mqtt Support https://www.eclipse.org/paho/clients/python/
# pip3 install paho-mqtt
from ev3dev.ev3 import *
import paho.mqtt.client as mqtt
import time
import helper
import sys
import json
import threading
restrictedMode = 0
sensor = hubAddress = deviceId = sharedAccessKey = owmApiKey = owmLocation = None

grab_motor = Motor('outA')
left_motor = Motor('outB')
right_motor = Motor('outC')

spkr = Sound()

def config_defaults():
    global sensor, hubAddress, deviceId, sharedAccessKey, owmApiKey, owmLocation
    print('Loading default config settings')

def config_load():
    global sensor, hubAddress, deviceId, sharedAccessKey, owmApiKey, owmLocation
    try:
        if len(sys.argv) == 2:
            print('Loading {0} settings'.format(sys.argv[1]))

            config_data = open(sys.argv[1])
            config = json.load(config_data)
            hubAddress = config['IotHubAddress']
            deviceId = config['DeviceId']
            sharedAccessKey = config['SharedAccessKey']
        else:
            config_defaults()
    except:
        config_defaults()

def on_connect(client, userdata, flags, rc):
    print("Connected with result code: %s" % rc)
    client.subscribe(help.hubTopicSubscribe)

def on_disconnect(client, userdata, rc):
    print("Disconnected with result code: %s" % rc)
    client.username_pw_set(help.hubUser, help.generate_sas_token(help.endpoint, sharedAccessKey))
    #sensor_stop.set()

def on_message(client, userdata, msg):
    print("{0} - {1} ".format(msg.topic, str(msg.payload)))
    # Do this only if you want to send a reply message every time you receive one
    # client.publish("devices/mqtt/messages/events", "REPLY", qos=1)

    try:
        global restrictedMode
        print(msg.topic, msg.payload)
        state = json.loads(msg.payload.decode("utf-8"))
        
        if restrictedMode is not None and restrictedMode == 1 and "isPublic" in state.keys()  and state["isPublic"] == 1:
            return 
        if 'leftDuration' in state:
            print("Right:", state['leftDuration'])
            print("Speed:", state['leftSpeed'])
            left_motor.run_timed(speed_sp = state['leftSpeed'],time_sp = state['leftDuration'])
        if 'rightDuration' in state:
            print("Right:", state['rightDuration'])
            print("Speed:", state['rightSpeed'])
            right_motor.run_timed(speed_sp = state['rightSpeed'],time_sp = state['rightDuration'])
        if 'grabDuration' in state:
            print("grab:", state['grabDuration'])
            print("Speed:", state['grabSpeed'])
            grab_motor.run_timed(speed_sp = state['grabSpeed'],time_sp = state['grabDuration'])
        if 'leftForever' in state:
            left_motor.run_forever(speed_sp = state['leftSpeed'])
        if 'leftStop' in state:
            left_motor.stop()
        if 'rightForever' in state:
            right_motor.run_forever(speed_sp = state['rightSpeed'])
        if 'rightStop' in state:
            right_motor.stop()
        if  'sayGoodbye' in state:
            spkr.speak('Goodbye')
        if  'playSound' in state:
            spkr.play('mrbrick.wav')
        if  'restrictedMode' in state:
            restrictedMode = state['restrictedMode']
        
    except:
        print("Failed handling command: ", sys.exc_info());#[0]);

def on_publish(client, userdata, mid):
    print("Message {0} sent from {1} data: {2}".format(str(mid), deviceId, userdata))


def on_disconnect(client, userdata, rc):
    if rc != 0:
        print("Disconnected: " + str(rc))

def publish():
    lastColor = 0
    while True:
        try:
            cl = ColorSensor()
            # Put the color sensor into COL-REFLECT mode
            # to measure reflected light intensity.
            # In this mode the sensor will return a value between 0 and 100
            cl.mode='COL-COLOR'
            newColor =  cl.value()
            if newColor != lastColor:
                client.publish(help.hubTopicPublish,newColor) 
                lastColor = newColor           
            time.sleep(0.1)
        
                    
            #spkr = Sound()

            # Play 'bark.wav':
            #spkr.play_file('bark.wav')

            # Introduce yourself:
            #spkr.speak('Goodbye')

            # Play a small song
            # spkr.play_song((
            #     ('D4', 'e3'),
            #     ('D4', 'e3'),
            #     ('D4', 'e3'),
            #     ('G4', 'h'),
            #     ('D5', 'h')
            # ))
        except KeyboardInterrupt:
            print("IoTHubClient sample stopped")
            return

        except:
            print("Unexpected error")
            time.sleep(4)




config_load()

help = helper.Helper(hubAddress, deviceId, sharedAccessKey)

try:
    client = mqtt.Client(deviceId, mqtt.MQTTv311)

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    client.on_publish = on_publish

    client.username_pw_set(help.hubUser, help.generate_sas_token(help.endpoint, sharedAccessKey))

    client.tls_set("baltimorebase64.cer") # Baltimore Cybertrust Root exported from Windows 10 using certlm.msc in base64 format
    client.connect(hubAddress, 8883)

    client.loop_start()
    publish()
except:
    left_motor.stop()
    right_motor.stop()

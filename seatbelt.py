import time
import kafka
import json

producer = kafka.KafkaProducer(bootstrap_servers=['192.168.16.245:9092'], value_serializer=lambda m: json.dumps(m).encode('ascii'))

doors = list("111111")

choices = {
    "BeltReminderSensorRL_MS": 0,
    "BeltReminderSensorRM_MS": 0,
    "BeltReminderSensorRR_MS": 0,
    "BeltReminderSensor_MS": 0,
    "BeltRmderSensorRow3L_MS": 0,
    "BeltRmderSensorRow3R_MS": 0,
    "DrivSeatBeltBcklState_MS": 0,
    "PassSeatBeltBcklState_MS": 0,
    "LowBeamIndication_MS": 0,
    "MainBeamIndication_MS": 0
}

payload = {
        "vehicle_id": "f-type",
        "source": "test",
        "signal": None,
        "timestamp": int(round(time.time() * 1000)),
        "command": "EVENT",
        "attributes":{
            "value" : None
        }
}

def send_reversed(signal, door = None, window = None):

    if window != None:
        if door == 0:
            payload["signal"] = signal
            payload["attributes"]["value"] = int(window)
            producer.send( 'androidbigdata' , payload)
        elif door == 1:
            payload["signal"] = signal
            payload["attributes"]["value"] = int(window)
            producer.send( 'androidbigdata' , payload)
        elif door == 2:
            payload["signal"] = signal
            payload["attributes"]["value"] = int(window)
            producer.send( 'androidbigdata' , payload)
        elif door == 3:
            payload["signal"] = signal
            payload["attributes"]["value"] = int(window)
            producer.send( 'androidbigdata' , payload)

    elif door != None and window == None:
        if doors[door] == "1":
            doors[door] = "0"
            payload["signal"] = signal
            payload["attributes"]["value"] = int("".join(doors), 2)
            producer.send( 'androidbigdata' , payload)

        else:
            doors[door] = "1"
            payload["signal"] = signal
            payload["attributes"]["value"] = int("".join(doors), 2)
            producer.send( 'androidbigdata' , payload)

    else:

        if choices[signal] == 0:
            payload["signal"] = signal
            payload["attributes"]["value"] = 1
            producer.send( 'androidbigdata' , payload)
            choices[signal] = 1

        else:
            payload["signal"] = signal
            payload["attributes"]["value"] = 0
            producer.send( 'androidbigdata' , payload)
            choices[signal] = 0


while True:
    print("Driver Seatbelt           \t0")
    print("Passenger Seatbelt        \t1")
    print("Belt Reminder Sensor RL   \t2")
    print("Belt Reminder Sensor RR   \t3")
    #print("BeltReminderSensorRM_MS  \t1")
    #print("BeltReminderSensor_MS    \t3")
    #print("BeltRmderSensorRow3L_MS  \t4")
    #print("BeltRmderSensorRow3R_MS  \t5")
    print("Driver Door               \t4")
    print("Passenger Door            \t5")
    print("Rear Driver Door          \t6")
    print("Rear Passenger Door       \t7")
    print("Trunk                     \t8")
    print("Hood                      \t9")
    print("Driver Window Position    \t10")
    print("Passenger Window Position \t11")
    print("Rear Driver Window Pos    \t12")
    print("Rear Passenger Window Pos \t13")
    print("Low Beams                 \t14")
    print("High Beams                \t15")



    select = str(input("Please select signal to toggle: "))

    if select == "0":
        send_reversed("DrivSeatBeltBcklState_MS")

    elif select == "1":
        send_reversed("PassSeatBeltBcklState_MS")

    elif select == "2":
        send_reversed("BeltReminderSensorRL_MS")

    elif select == "3":
        send_reversed("BeltReminderSensorRR_MS")

    elif select == "4":
        send_reversed("DoorStatusMS_MS", 5)

    elif select == "5":
        send_reversed("DoorStatusMS_MS", 4)

    elif select == "6":
        send_reversed("DoorStatusMS_MS", 3)

    elif select == "7":
        send_reversed("DoorStatusMS_MS", 2)

    elif select == "8":
        send_reversed("DoorStatusMS_MS", 1)

    elif select == "9":
        send_reversed("DoorStatusMS_MS", 0)

    elif select == "10":
        pos = str(input("Please select window pos 1-5: "))
        send_reversed("DriverWindowPosition_MS", 0, pos)

    elif select == "11":
        pos = str(input("Please select window pos 1-5: "))
        send_reversed("PassWindowPosition_MS", 1, pos)

    elif select == "12":
        pos = str(input("Please select window pos 1-5: "))
        send_reversed("RearDriverWindowPos_MS", 2, pos)

    elif select == "13":
        pos = str(input("Please select window pos 1-5: "))
        send_reversed("RearPassWindowPos_MS", 3, pos)

    elif select == "14":
        send_reversed("LowBeamIndication_MS")

    elif select == "15":
        send_reversed("MainBeamIndication_MS")


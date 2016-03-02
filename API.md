To the Server
--------------

#### (STATUS) Request the status of a vehicle with the given vehicle_id:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "STATUS"
}
```

#### (ALL_SIGNALS) Request the list of all signals from the vehicle:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "ALL_SIGNALS"
}
```

#### (SIGNAL_DESCRIPTOR) Request for the signal_decsriptor information for a signalName:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "SIGNAL_DESCRIPTOR",
    "signalName": "some_signal"
}
```

#### (SUBSCRIBE) Request to subscribe to signals:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "SUBSCRIBE",
    "signals": [...]
}
```

#### (UNSUBSCRIBE) Request to unsubscribe to signals:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "UNSUBSCRIBE",
    "signals": [...]
}
```

#### (HISTORY) Request for historical data for signalName:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "HISTORY",
    "signalName": "some_signal",
    "start": 1456768000000,
    "stop": 1456768999999
}
```


From the Server
---------------

#### (STATUS) Response to a vehicle status request:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "STATUS",
    "status": ["CONNECTED"|"NOT_CONNECTED"|"INVALID_VEHICLE_ID"]
    "number_doors": <num_doors>,
    "number_windows": <num_windows>,
    "number_seats": <num_seats>,
    "driver_side": ["LEFT"|"RIGHT"]
}
```

#### (ALL_SIGNALS) Response to an all signals request:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "ALL_SIGNALS",
    "signals": [...]
}
```

#### (SIGNAL_DESCRIPTOR) Response to a signal_decsriptor request with the information for a signalName:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "SIGNAL_DESCRIPTOR",
    "signalName": "some_signal",
    "descriptor": {...}
}
```

#### (HISTORY) Response to a request for historical data for signalName:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "HISTORY",
    "signalName": "some_signal",
    "start": 1456768000000,
    "stop": 1456768999999,
    "events": [(see event data description below)]
}
```

#### (EVENT) A signalName change/event occurred:
```
{
    "attributes": {
        "value": "??? what should be here ???"
    },
    "vehicle_id": "vehicle_55",
    "signalName": "IVI_TONE_CHANGE",
    "location": {
        "coordinates": [9.454, 61.163],
        "type": "Point"
    },
    "source": "DTM-DA-TEST",
    "timestamp": 1456768736936,
    "command": "EVENT"
}
```

#### (ERROR) An error to a request occurred:
```
{
    "vehicle_id": "vehicle_55",
    "timestamp": 1456768736936,
    "command": "ERROR",
    "error": "error_message",
    "orig_command": "<SIGNALS|SIGNAL_DESCRIPTOR|HISTORY>"
    "signalName": <signal_if_available>
}
```

Possible errors:
- A vehicle_id doesn't exist for any command, except for the status request, which entire purpose is to find out if the vehicle_id exits. This error probably shouldn't happen, because I'll always be making a vehicle status request with any vehicle_id to confirm this, but it's still a possibility.

- A signal_descriptor request is made for a signalName that doesn't exist or the request is made for a signalName that doesn't have description information.

- A history request is made for a signalName that doesn't exist.

- A subscribe/unsubscribe is made for a signalName that doesn't exist. I don't think we need to send an error in this case, though, do we? If you want to, I'll just log it then ignore it most likely.




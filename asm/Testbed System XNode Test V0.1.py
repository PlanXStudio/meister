from serial import Serial
import time

PORT = "/comm/ttyUSB0"

comm = Serial(PORT, 115200, timeout = 0.01)

def protocol(cmd, _payload='00'):
    if cmd.lower().find('gasbreaker') != -1:
        cmd = '01'
    elif cmd.lower().find('gassensor') != -1:
        cmd = '11'    
    elif cmd.lower().find('kitchenfan') != -1:
        cmd = '02'
    elif cmd.lower().find('kitchenlight') != -1:
        cmd = '03'
    elif cmd.lower().find('kitchensensor') != -1:
        cmd = '12'
    elif cmd.lower().find('livingsensor1') != -1:
        cmd = '13'
    elif cmd.lower().find('livinglight') != -1:
        cmd = '05'
    elif cmd.lower().find('livingfan') != -1:
        cmd = '04'
    elif cmd.lower().find('livingsensor2') != -1:
        cmd = '14'
    elif cmd.lower().find('livingcurtain') != -1:
        cmd = '06'
    elif cmd.lower().find('pirsensor') != -1:
        cmd = '15'
    elif cmd.lower().find('doorsensor') != -1:
        cmd = '16'
    elif cmd.lower().find('doorlight') != -1:
        cmd = '08'
    elif cmd.lower().find('doorlock') != -1:
        cmd = '07'

    if _payload.lower().find('on') != -1:
        _payload = '01'
    elif _payload.lower().find('off') != -1:
        _payload = '00'
    
    payloadlength = int(len(_payload)/2)
    
    payloadlength = '{:02x}'.format(payloadlength)         
    
    ptc = dict(Start='76',Cmd=cmd,Payloadlength=payloadlength,Payload=_payload,End='3E')
        
    msg =  ptc['Start'] + ptc['Cmd'] + ptc['Payloadlength'] + ptc['Payload'] + ptc['End']
        
    print("Sending msg : ", msg, "to BroadCast")
    
    comm.write(bytes(msg, encoding='utf8'))
      
    time.sleep(0.5)

def main():
    msg = ''
    payload = ''

    comm.flushInput()
    comm.flushOutput()

    print("start!")

    protocol('gasbreaker','On')
    protocol('kitchenlight','On')
    protocol('kitchenfan','On')
    protocol('livinglight','On')
    protocol('livingfan','On')
    protocol('livingcurtain','On')
    protocol('doorlight','On')
    protocol('doorlock','On')

    protocol('gasbreaker','Off')
    protocol('kitchenlight','Off')
    protocol('kitchenfan','Off')
    protocol('livinglight','Off')
    protocol('livingfan','Off')
    protocol('livingcurtain','Off')
    protocol('doorlight','Off')
    protocol('doorlock','Off')

    protocol('kitchensensor')
    protocol('livingsensor1')
    protocol('livingsensor2')
    protocol('doorsensor')
    protocol('pirsensor','On')
    protocol('gassensor','On')

    flag_pir = True
    pre_time = time.time()

    while True:
        if flag_pir:
            if ((time.time() - pre_time) > 10):
                protocol('pirsensor','Off')
                protocol('gassensor','Off')
                flag_pir = False

        msg = comm.read()     

        if msg is not None:
            payload += msg.decode()

        if len(payload) >= 8:

            if payload[-2:] == '3E': 
                if payload[:2] != '76':
                    payload = payload[2:]
                
                print(payload)

                r_payload = [payload[i:i+2] for i in range(0, len(payload), 2)]

                if r_payload[1] == '22':
                    temp = int(r_payload[3],16)
                    humi = int(r_payload[4],16)

                    print("kitchen Temperature : %d, Humidity : %d\n"%(temp,humi))

                    if len(payload) > 12:
                        payload = payload[12:]
                    else:
                        payload = ''
                
                elif r_payload[1] == '23':
                    temp = int(r_payload[3],16)
                    humi = int(r_payload[4],16)

                    dust = ((int(r_payload[5],16))<<8) + int(r_payload[6],16)
                
                    print("living Temperature : %d, Humidity : %d, Dust : %d\n"%(temp,humi,dust))

                    if len(payload) > 16:
                        payload = payload[16:]
                    else:
                        payload = ''
                
                elif r_payload[1] == '24':

                    light = ((int(r_payload[3],16))<<8) + int(r_payload[4],16)
                
                    print("light : %d\n"%(light))

                    if len(payload) > 12:
                        payload = payload[12:]
                    else:
                        payload = ''
                        
                elif r_payload[1] == '25':
                    pir = int(r_payload[3],16)
                
                    print("pir : %d\n"%(pir))

                    if len(payload) > 10:
                        payload = payload[10:]
                    else:
                        payload = ''
                        
                elif r_payload[1] == '26':
                    temp = int(r_payload[3],16)
                    humi = int(r_payload[4],16)

                    print("door Temperature : %d, Humidity : %d\n"%(temp,humi))

                    if len(payload) > 12:
                        payload = payload[12:]
                    else:
                        payload = ''

                elif r_payload[1] == '21':
                    gas = int(r_payload[3],16)
                
                    print("gas : %d\n"%(gas))
                    
                    if len(payload) > 10:
                        payload = payload[10:]
                    else:
                        payload = ''

        time.sleep(.01)   

if __name__ == "__main__":
    main()
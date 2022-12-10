import socket
from pythonosc import udp_client
import json
import numpy
 


def denoise_range(list_range):

    return sum(list_range)/len(list_range)



    


if __name__ == '__main__':



    localIP     = "0.0.0.0"
    
    Maxport     = 52521


    bufferSize  = 1024

    



    

    # Create a datagram socket

    UDPServerSocket_fromUWB = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    OSC_toMax = udp_client.SimpleUDPClient('127.0.0.1',52521)

    # Bind to address and ip

    UDPServerSocket_fromUWB.bind(('0.0.0.0', 55555))
    #OSC_toMax.bind(('0.0.0.0', 52521))


    

    print("UDP server up and listening")

    list_anchor_1_data = []
    list_anchor_2_data = []
    current_average_data_2 = 0
    current_average_data_1 = 0
    count = 0
    # Listen for incoming datagrams

    while(True):
        
        bytesAddressPair = UDPServerSocket_fromUWB.recvfrom(bufferSize)

        message = bytesAddressPair[0]

        address = bytesAddressPair[1]

        clientMsg = "Message from Client:{}".format(message)
        clientIP  = "Client IP Address:{}".format(address)
        message = message.decode()
        str_message = message.replace("x","")
        print(str_message)
        json_object = json.loads(str_message)
        length_links = len(json_object['links'])
        print(length_links)
      
        if length_links == 2:
            anchor_1_id = json_object['links'][0]['a'] 
            anchor_2_id = json_object['links'][1]['a'] 
            anchor_1_range = json_object['links'][0]['r']
            anchor_2_range = json_object['links'][1]['r']
            difference_noise_1 = abs(current_average_data_1) - abs(float(anchor_1_range))   
            difference_noise_2 = abs(current_average_data_2) - abs(float(anchor_2_range)) 

            if abs(difference_noise_1) > 5 or abs(difference_noise_2) > 5:
                print('Noise!!')
            else:
                if count <=2:
                    anchor_1_range = float(anchor_1_range)
                    anchor_2_range = float(anchor_2_range)
                    list_anchor_1_data.append(anchor_1_range)
                    list_anchor_2_data.append(anchor_2_range)
                    count = count+1
                else:
                    print(f"the length is :{len(list_anchor_2_data)}")
                    anchor_1_range_denoised = denoise_range(list_anchor_1_data)
                    anchor_2_range_denoised = denoise_range(list_anchor_2_data)
                    current_average_data_1 = anchor_1_range_denoised
                    current_average_data_2 = anchor_2_range_denoised

                    print(f"{anchor_1_id}'s range is {anchor_1_range_denoised}")
                    print(f"{anchor_2_id}'s range is {anchor_2_range_denoised}")
                    count = 0
                    list_anchor_1_data = []
                    list_anchor_2_data = []
                    OSC_toMax.send_message('Anchor_1',float(anchor_1_range_denoised))
                    OSC_toMax.send_message('Anchor_2',float(anchor_2_range_denoised))
                    #print(clientIP)



            
        elif length_links == 1:

            anchor_1_id = json_object['links'][0]['a'] 
            anchor_1_range = json_object['links'][0]['r']
            difference_noise_1 = abs(current_average_data_1) - abs(float(anchor_1_range))  
            if abs(difference_noise_1) > 5:
                print('Noise!!')
            else:
                if count <=2:
                    anchor_1_range = float(anchor_1_range)
                    list_anchor_1_data.append(anchor_1_range)
                    count = count+1
                else:
                    anchor_1_range_denoised = denoise_range(list_anchor_1_data)
                    current_average_data_1 = anchor_1_range_denoised
                    print(f"{anchor_1_id}'s range is {anchor_1_range_denoised}")
                    count = 0
                    list_anchor_1_data = []
                    OSC_toMax.send_message('Anchor_1',float(anchor_1_range_denoised))
                    OSC_toMax.send_message('Anchor_2',0)




        
        elif length_links == 0:
            print("No Anchor detected!")
            OSC_toMax.send_message('Anchor_1',0)
            OSC_toMax.send_message('Anchor_2',0)
            
            list_anchor_1_data = []
            list_anchor_2_data = []
            count = 0
            current_average_data_2 = 0
            current_average_data_1 = 0



        else:
            print('The number of Anchor is out of range')
                
            list_anchor_1_data = []
            list_anchor_2_data = []
            count = 0
            current_average_data_2 = 0
            current_average_data_1 = 0


 






import cv2
import numpy as np
import tensorflow as tf
import neuralgym as ng
from inpaint_model import InpaintCAModel
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from PIL import Image
import io
import time
import threading
from detect_human import DetectorAPI
import evaluate




ng.get_gpus(1)

inp_model = InpaintCAModel()
# Inpaint Model 체크포인트
# place2_checkpoint_dir = "/Users/singwanghyeon/PycharmProjects/tfcoreml/generative_inpainting-master/model_logs/release_places2_256"
place2_checkpoint_dir = "models/inpaint_places2"
# imagenet_checkpoint_dir = "/Users/singwanghyeon/PycharmProjects/tfcoreml/generative_inpainting-master/model_logs/release_imagenet_256"
imagenet_checkpoint_dir = "models/inpaint_imagenet"

det_model_path = '/Users/singwanghyeon/Desktop/frozen_inference_graph.pb'
# Detect human API 초기화
det_model = DetectorAPI(path_to_ckpt=det_model_path)


# firebase에서 가져온 style 이미지 저장 디렉토리
styleimg_indir = "/Users/singwanghyeon/PycharmProjects/Taskimgs/style.png"
# style result output dir
styleimg_outdir = "/Users/singwanghyeon/PycharmProjects/Taskimgs/style_result.png"


# cred = credentials.Certificate('/Users/singwanghyeon/PycharmProjects/inpaint-server-firebase-adminsdk-ei5g5-fc1a36a1d1.json')
cred = credentials.Certificate('/Users/singwanghyeon/Desktop/inpaint-server-firebase-adminsdk-ei5g5-fc1a36a1d1.json')
app = firebase_admin.initialize_app(cred, {
    'storageBucket': 'inpaint-server.appspot.com'
})
bucket = storage.bucket(app=app)



def inpaint_model_run(image, mask, modelname):
    # your own directory
    Down_url = f"/Users/singwanghyeon/PycharmProjects/tfcoreml/inpaint.png"

    ############### INPAINT MODEL RUN! ###################
    if modelname == "place2" :
        checkpoint_dir = place2_checkpoint_dir
    else :
        checkpoint_dir = imagenet_checkpoint_dir

    assert image.shape == mask.shape

    h, w, _ = image.shape
    grid = 8
    image = image[:h // grid * grid, :w // grid * grid, :]
    mask = mask[:h // grid * grid, :w // grid * grid, :]
    print('Shape of image: {}'.format(image.shape))

    image = np.expand_dims(image, 0)
    mask = np.expand_dims(mask, 0)
    input_image = np.concatenate([image, mask], axis=2)

    sess_config = tf.ConfigProto()
    sess_config.gpu_options.allow_growth = True
    with tf.Session(config=sess_config) as sess:
        input_image = tf.constant(input_image, dtype=tf.float32)
        print('input_image', input_image)
        output = inp_model.build_server_graph(input_image)
        output = (output + 1.) * 127.5
        output = tf.reverse(output, [-1])
        output = tf.saturate_cast(output, tf.uint8)

        # load pretrained model
        vars_list = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES)
        assign_ops = []
        for var in vars_list:
            vname = var.name
            from_name = vname
            var_value = tf.contrib.framework.load_variable(checkpoint_dir, from_name)
            assign_ops.append(tf.assign(var, var_value))
        sess.run(assign_ops)
        print('Model loaded.')
        result = sess.run(output)
        # cv2.imshow("asd",result[0][:, :, ::-1])
        # cv2.waitKey()
        cv2.imwrite(Down_url, result[0][:, :, ::-1])

        #### UPLOAD CODE ####

        img = Image.open(Down_url, mode='r')
        imgByteArr = io.BytesIO()
        img.save(imgByteArr, format='PNG')
        imgByteArr = imgByteArr.getvalue()

        return imgByteArr



def detection_model_run(img):
    realbox = []

    threshold = 0.7
    boxes, scores, classes, num = det_model.processFrame(img)

    # Visualization of the results of a detection.
    # print(boxes)
    for i in range(len(boxes)):
        # Class 1 represents human
        if classes[i] == 1:
            if list(boxes[i])[0] != 0 and list(boxes[i])[1] != 0 and list(boxes[i])[2] != 0 and list(boxes[i])[3] != 0:
                realbox.append(list(boxes[i]))
            print(list(boxes[i]))
            box = boxes[i]
            cv2.rectangle(img, (box[1], box[0]), (box[3], box[2]), (255, 0, 0), 2)

    cv2.imwrite("/Users/singwanghyeon/Desktop/detect.png",img)
    stra = ""
    a = 0

    for i in realbox:
        for j in i:
            stra += str(j)
            stra += "."
        a += 1
        if a != len(realbox):
            stra += "/"

    return stra

def style_model_run(model_name):
    # style models
    if model_name == 'monet' :
        # style_model = f"/Users/singwanghyeon/PycharmProjects/StyleModels/{model_name}"
        style_model = f"models/StyleModels/{model_name}"
    else :
        # style_model = f"/Users/singwanghyeon/PycharmProjects/StyleModels/{model_name}.ckpt"
        style_model = f"models/StyleModels/{model_name}.ckpt"

    evaluate.ffwd_to_img(styleimg_indir, styleimg_outdir, style_model)

    img = Image.open(styleimg_outdir, mode='r')
    imgByteArr = io.BytesIO()
    img.save(imgByteArr, format='PNG')
    imgByteArr = imgByteArr.getvalue()

    return imgByteArr



def thread_run():
    global num
    print("--",time.ctime(),'--')

    blob = bucket.blob("Queue.txt")
    strdata = blob.download_as_string()
    strdata = strdata.decode('utf-8').split('.')
    print("strdata : ",len(strdata))

    # queuer(strdata)가 none 일경우
    if len(strdata) == 1:
        print("thread run... Current Queue txt :",strdata)
    else:
        ## 테스크txt 수정 업로드 taskname = style/wave/user1 ##
        taskname = strdata[1]
        #ex) strdata[1] = inpaint/user1
        print(taskname)
        try:
            #inpaint  :  (img, img) -> img
            #detect   :  (img) -> txt
            #stayle   :  (img) -> img
            task = taskname.split("/")

            ### 테스크별 프로퍼티 초기화 오류일시 스킵 ###
            if task[0] == "inpaint":
                ####### inpaint image download #######

                ## mask image download ##
                blob = bucket.blob(f"{taskname}m.png")
                dataka1 = blob.download_as_string()
                pilmask = Image.open(io.BytesIO(dataka1))
                mask = cv2.cvtColor(np.array(pilmask), cv2.COLOR_RGB2BGR)

                ## original image download ##
                blob = bucket.blob(f"{taskname}o.png")
                dataka = blob.download_as_string()
                pilimage = Image.open(io.BytesIO(dataka)).convert('RGB')
                image = cv2.cvtColor(np.array(pilimage), cv2.COLOR_RGB2BGR)

            elif task[0] == "detection":
                ####### detection image download #######
                blob = bucket.blob(f"{taskname}.png")
                detectdata = blob.download_as_string()
                pildetimage = Image.open(io.BytesIO(detectdata)).convert('RGB')
                detimage = cv2.cvtColor(np.array(pildetimage), cv2.COLOR_RGB2BGR)

            elif task[0] == "style":
                ####### stayletrans image download #######
                blob = bucket.blob(f"{taskname}.png")
                stayledata = blob.download_as_string()
                pilstyimage = Image.open(io.BytesIO(stayledata)).convert('RGB')
                styimage = cv2.cvtColor(np.array(pilstyimage), cv2.COLOR_RGB2BGR)
                cv2.imwrite(styleimg_indir, styimage)


            ### list pop first and Overwrite to server ###
            strdata.pop(1)
            strdata = '.'.join(strdata)
            strdata = strdata.encode()
            blob = bucket.blob('Queue.txt')
            blob.upload_from_string(
                strdata,
                content_type='text/plain'
            )
            print(blob.public_url)



            ### 업로드 ###
            if task[0] == "inpaint":
                print("inpaint")
                ####### inpaint image upload #######
                # task[1] = "place2" or "imagenet"
                inpaintimgByteArr = inpaint_model_run(image, mask, task[1])
                blob = bucket.blob(f"{taskname}_result.png")
                blob.upload_from_string(
                    inpaintimgByteArr,
                    content_type='image/png'
                )
            elif task[0] == "detection":
                ####### detection image upload #######
                print("detection")
                detectboxes = detection_model_run(detimage)
                detectboxes = detectboxes.encode()
                blob = bucket.blob(f"{taskname}_result.txt")
                blob.upload_from_string(
                    detectboxes,
                    content_type='text/plain'
                )

            elif task[0] == "style":
                ####### stayletrans image upload #######
                print("style")
                blob = bucket.blob(f"{taskname}_result.png")
                # task[1] = "waive" or "monet" etc
                styleimgByteArr = style_model_run(task[1])
                blob.upload_from_string(
                    styleimgByteArr,
                    content_type='image/png'
                )

        except Exception as ex:
            print("error!","Current Queue txt : ",strdata , ex)
    threading.Timer(0.5, thread_run).start()

thread_run()





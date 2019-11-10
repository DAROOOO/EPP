import argparse

import cv2
import numpy as np
import tensorflow as tf
import neuralgym as ng


from inpaint_model import InpaintCAModel


parser = argparse.ArgumentParser()
parser.add_argument('--image', default='', type=str,
                    help='The filename of image to be completed.')
parser.add_argument('--mask', default='', type=str,
                    help='The filename of mask, value 255 indicates mask.')
parser.add_argument('--output', default='output.png', type=str,
                    help='Where to write output.')
parser.add_argument('--checkpoint_dir', default='', type=str,
                    help='The directory of tensorflow checkpoint.')


if __name__ == "__main__":
    ng.get_gpus(1)
    args = parser.parse_args()

    model = InpaintCAModel()
    image = cv2.imread(args.image)
    mask = cv2.imread(args.mask)

    assert image.shape == mask.shape

    h, w, _ = image.shape
    grid = 8
    image = image[:h//grid*grid, :w//grid*grid, :]
    mask = mask[:h//grid*grid, :w//grid*grid, :]
    print('Shape of image: {}'.format(image.shape))

    image = np.expand_dims(image, 0)
    mask = np.expand_dims(mask, 0)
    input_image = np.concatenate([image, mask], axis=2)

    sess_config = tf.ConfigProto()
    sess_config.gpu_options.allow_growth = True
    with tf.Session(config=sess_config) as sess:
        input_image = tf.constant(input_image, dtype=tf.float32)
        print('input_image',input_image)
        output = model.build_server_graph(input_image)
        output = (output + 1.) * 127.5
        output = tf.reverse(output, [-1])
        output = tf.saturate_cast(output, tf.uint8)

        # load pretrained model
        vars_list = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES)
        assign_ops = []
        for var in vars_list:
            vname = var.name
            from_name = vname
            var_value = tf.contrib.framework.load_variable(args.checkpoint_dir, from_name)
            assign_ops.append(tf.assign(var, var_value))
        sess.run(assign_ops)
        print('Model loaded.')
        result = sess.run(output)
        cv2.imwrite(args.output, result[0][:, :, ::-1])

        #pb구하는 코드. output_node_name은 해당 그래프의 마지막연산의 노드로 해야함
        '''     
        print('out',output.op)
        graph_def = tf.get_default_graph().as_graph_def()
        output_node_name = 'saturate_cast'
        constant_graph = tf.graph_util.convert_variables_to_constants(sess, graph_def, output_node_name.split(","))
    with tf.gfile.FastGFile('/Users/singwanghyeon/PycharmProjects/tfcoreml/generative_inpainting-master/model_logs/hope.pb', mode='wb') as f:
        f.write(constant_graph.SerializeToString())
        '''

        # result = sess.run(output)
        # print(output.op)
        # print(type(result))
        # cv2.imshow(args.output, result[0][:, :, ::-1])
        # cv2.waitKey()
        # node_names = [node.name for node in tf.get_default_graph().as_graph_def().node]
        #print(node_names)


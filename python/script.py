import ddddocr
import base64
from io import BytesIO

def init_ocr():
    return ddddocr.DdddOcr(show_ad=False)

def recognize_captcha(ocr_instance, image_data):
    try:
        # 将 base64 图片数据转换为字节
        image_bytes = base64.b64decode(image_data)
        # 创建 BytesIO 对象
        image_stream = BytesIO(image_bytes)
        # 识别验证码
        result = ocr_instance.classification(image_stream.read())
        return result
    except Exception as e:
        return f"Error: {str(e)}" 
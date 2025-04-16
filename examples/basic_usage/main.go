package main

import (
	"fmt"
	"log"

	"github.com/ELSS-ZION/CaptchaOCR/pkg/captchaocr"
)

func main() {
	// 初始化验证码识别环境
	if err := captchaocr.Initialize(); err != nil {
		log.Fatalf("初始化失败: %v", err)
	}
	// 程序结束时清理资源
	defer captchaocr.Cleanup()

	// 示例：使用 base64 编码的图片数据
	// 这是一个示例验证码图片的 base64 数据（不包含 data:image/jpeg;base64, 前缀）
	imageData := "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAeAGQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD2S4bbb7MnYOpHTk5yKxJmKrgE9OfyrZvTEdjlRls4Pcn39qxJ2Tpx071z051Obodck9dhI2ZiF2tggnHtzULFhcB9zZxu+UDG4fX1qcMvHD8dyD/ShsyWybk2sp4Hvx0NdNSSS1Zn6jCvK7t2ep9/8f8AGo5ELfdyR6Y4/X/PvU0aYiH3m/maSVAyMAc5HSs1JJplEIjIXG7rUUjFd2Fxg9c+/tVn7o4qOUkRtg4yK6KdSaehSRSklZ+VdvpkVDImCd24DnnnpV+WMtGxx9axY9wlbeW6HOTnv2rpWJcnqacuhMq54B/OlwSe3SlVgTgZYnPQ4/rU0SDeAVJ9RXRTqybITsRKrKvJx+P+FNIVk5OPpkfzqzLGGToc+lUx9/1z1qZSk2aE0YdG3I7Yz2Gc1A06RNgkMe+Tn1qyfvdf1qm/+uJOOB0PTvWMuezKS0C4uAyLtVlUjG4GopJlKjHXPpxSKP3KYP8AdH8qr3f3V/D+lc8a0pys2NRNGeQyW0a4y/B/n/KsTUIyT868Y/DPtVy6P7tB/s/1NZl4eF/3TWMasnVd2U0i3GQI1Bz90fy/wpJTxzjiqkdzbLEiNLhgMHcpXn9KdLcQugCzRs+efm7fiMUo1JdxWBvvKB3NJN/qX/3TRcnNug9G/lTLncbaQr1K4H51D1Gth0P3x9RSw9B9TSQgCMYHb+lLb/cH0H8qiDs7gf/Z"

	// 调用验证码识别函数
	result, err := captchaocr.RecognizeCaptcha(imageData)
	if err != nil {
		log.Fatalf("识别失败: %v", err)
	}

	// 打印结果
	fmt.Printf("验证码识别结果: %s\n", result)
}

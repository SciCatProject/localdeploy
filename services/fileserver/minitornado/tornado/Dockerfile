FROM ubuntu:artful


RUN apt-get update && apt-get install -y \
	python3-tornado 

COPY . /usr/src/app/

WORKDIR /usr/src/app/
EXPOSE 8888

CMD ["python3","app2.py"]

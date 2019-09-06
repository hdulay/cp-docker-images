deps:
	mvn dependency:copy-dependencies
	
build: deps
	docker build --rm -t jupyter/ijava .

run:
	docker run -itd -p 8888:8888 jupyter/ijava


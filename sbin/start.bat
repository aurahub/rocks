docker run -e PRO_SPEC_T=dev --name lime -p 10000:10000 -v %cd%/../src:/project -w /project/Release -it --rm  lizongti/lime:latest ./Server
PAUSE
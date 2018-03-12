import os

import tornado.ioloop
import tornado.web
from tornado.options import define, options, parse_command_line

define("port", default=8888, help="run on the given port", type=int)

define("debug", default=False, help="run in debug mode")



class MainHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("scicat hdf5 tornado file server")

def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
    ])


def main():
    app = tornado.web.Application(
        [
            (r"/", MainHandler),
            ],
        cookie_secret="__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__",
        template_path=os.path.join(os.path.dirname(__file__), "templates"),
        static_path=os.path.join(os.path.dirname(__file__), "static"),
        xsrf_cookies=True,
        debug=options.debug,
        )
    app.listen(options.port)
    tornado.ioloop.IOLoop.current().start()


if __name__ == "__main__":
    main()

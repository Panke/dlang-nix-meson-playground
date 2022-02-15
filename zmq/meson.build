project('zmq-sample', 'd')

zmqd_dep = dependency('zmqd', method: 'dub')
zeromq_dep = dependency('zeromq', method: 'dub')

src = ['zmq_sample.d']
executable('zmq-sample', src, dependencies: zmqd_dep)

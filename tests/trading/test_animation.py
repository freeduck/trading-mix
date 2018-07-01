import matplotlib.pyplot as plt
import matplotlib.animation as animation
from trading.data import window_generator, pause_frame_generator
from trading.data import analyseData, foundPeakEvent, noPeakEvent
from trading.sql import connect
from trading.kraken import table_mapping, orders_table
from trading.octave import conf as peakConf
from trading.misc import desctructDict
from trading.recorder import record_event
from blinker import signal
from os.path import join
from functools import partial

from tkinter import Tk, Button


def init(plots, ax):
    ticks, fitted, psl = ax.plot([],
                                 [],
                                 [],
                                 [],
                                 [],
                                 [], 'b+')
    plots['ticks'] = ticks
    plots['fitted'] = fitted
    plots['psl'] = psl
    return ticks, fitted, psl


def update(frame, plots, ax):
    ticks, fitted, psl = desctructDict(plots, ('ticks',
                                               'fitted',
                                               'psl'))
    result = analyseData(peakConf, frame)
    xs, ys, xfit, yfit, xpeak, ypeak, trade = desctructDict(result,
                                                            ("x",
                                                             "y",
                                                             "xfit",
                                                             "yfit",
                                                             "xpeak",
                                                             "ypeak",
                                                             "tradeAdvise"))
    ax.set_xlim(min(xs), max(xs))
    ax.set_ylim(min(ys), max(ys))
    ticks.set_data(xs, ys)
    fitted.set_data(xfit, yfit)
    psl.set_data(xpeak, ypeak)
    return ticks, fitted, psl


def onFoundPeak(state, sender, data):
    state['continue'] = False


def onNoPeak(state, sender):
    print("No peak")
    state['continue'] = False


def controlPlot(state, play=True):
    state['continue'] = not state['continue']


state = {"continue": True}


def test_animation():
    global state
    db = connect("sqlite:///" + join('/home/kristian/projects/trading/data',
                                     'alldata.sqlite'))
    env = {**db, **table_mapping[orders_table]}
    fig, ax = plt.subplots()
    plots = {}

    onFoundPeak_fn = partial(onFoundPeak, state)
    onNoPeak_fn = partial(onNoPeak, state)

    # def onFoundPeak_fn(data):
    #     onFoundPeak(state, data)
    event = signal(foundPeakEvent)
    event.connect(onFoundPeak_fn)
    npevent = signal(noPeakEvent)
    npevent.connect(onNoPeak_fn)
    recordEvent = signal('record')
    fns = record_event(event, recordEvent)

    init_fn = partial(init, plots, ax)
    frame_fn = pause_frame_generator(state,
                                     window_generator(3600 * 3,
                                                      600,
                                                      **env))
    ani = animation.FuncAnimation(fig, update, frame_fn, init_fn, (plots, ax))
    # plt.show(block=False)
    # plt.show()
    top = Tk()
    top.geometry("150x100")

    def helloCallBack():
        controlPlot(state)

    def recordCallback():
        print("record")
        recordEvent.send('ui')

    B = Button(top, text="Hello", command=helloCallBack)
    B.place(x=50, y=0)
    RB = Button(top, text="Record", command=recordCallback)
    RB.place(x=50, y=50)
    plt.show(block=False)
    top.mainloop()

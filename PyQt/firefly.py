# -*- coding: utf-8 -*-
"""
Created on Fri Jul  7 20:07:56 2017

@author: zynq7020
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Jul  4 07:54:37 2017

@author: dell
"""

# -*- coding: utf-8 -*-
"""
Created on Mon Jul  3 15:12:18 2017

@author: dell
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Jun 28 15:02:23 2017

@author: dell
"""

from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
import sys, math, socket, threading, numpy
from time import ctime  
from functools import *

global ch_max
ch_max = 15
num = 0
host = '10.10.10.46'
port = 7
global channel
channel = 0
global pyinnerpts
pyinnerpts = []
for i in range(0,1024):
    if i % 2 == 0:
        pyinnerpts.append(int(i / 2))
    else:
        pyinnerpts.append(int(((math.sin(2*math.pi*(i-1)/1024))+1)*256))
global fft_data
x = numpy.divide(numpy.linspace(0,511, 512), 512)
y = numpy.floor(numpy.multiply(numpy.sin(numpy.multiply(x, 2 * numpy.pi)),256))
z = numpy.abs(numpy.fft.fft(y))
lz = list(z)
fft_data = []
for i in range(0, 1024):
    if i % 2 == 0:
        fft_data.append(i/2)
    else:
        fft_data.append(int(lz[int(i/2)]/512*4))
                    
class mainW(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setUi()
        self.setFixedSize(680,552)
        self.move(100, 100)
        self.setWindowTitle('PyQt信号检测系统')
        
        #开启第二个线程用于接收TCP服务器发过来的数据
        recvThread = threading.Thread(target = self.recvFromServer)
        recvThread.setDaemon(True)
        recvThread.start()
    
    def recvFromServer(self):
        global channel
        global fft_state
        while True:
            if channel == 14:
                if fft_state == 0:
                    self.paint.setPoints(pyinnerpts)
                else:
                    self.paint.setPoints(fft_data)
                print('This channel only for python inner Test')
            else:
                data = s.recv(5119)
                if not data:
                    exit()
                if len(data)== 2559:
                    str_data = data.decode()
                    list_str_data=str_data.split(',')
                    print(list_str_data)
                    list_data=list(map(int,list_str_data))
                    print(list_data)
                    if fft_state == 0:
                        self.paint.setPoints(list_data)
                    else:
                        y_data = []
                        for i in range(0, 512):
                            if (i+1)% 2  == 0:
                                y_data.append(list_data[i])
                        tmp_z = numpy.abs(numpy.fft.fft(y_data))
                        tmp_lz = list(tmp_z)
                        fftmp_data = []
                        for i in range(0, 512):
                            if i % 2 == 0:
                                fftmp_data.append(i/2)
                            else:
                                fftmp_data.append(int(tmp_lz[int(i/2)]/512*4))    
                       
                        print(fftmp_data)
                        self.paint.setPoints(fftmp_data)
                        
            
    def exit(self):
        s.close()
        sys.exit()
        
    def setUi(self):
        global ch_max
        #self.setGeometry(100,100,400,400)
        mWidget = QWidget()
        self.qhbox = QHBoxLayout()
        mWidget.setLayout(self.qhbox)
        self.setCentralWidget(mWidget)
        self.left_qvbox = QVBoxLayout()
        for i in range(0, ch_max):
            channel = i
            if channel == 14:
                self.rb = QRadioButton('py inner channel', self)
            else:
                self.rb = QRadioButton('channel' + str(i), self)
            #self.cb.setChecked(False)
            if i == 0:
                self.rb.setChecked(True)
            self.left_qvbox.addWidget(self.rb)
            self.rb.toggled.connect(partial(self.check_signal, i))
        self.fft = QCheckBox('FFT', self)
        self.left_qvbox.addWidget(self.fft)
        self.fft.setChecked(False)
        self.fft.stateChanged.connect(self.fft_handle)
        self.left_qvbox.addStretch(0)
        self.paint = PaintArea()
        self.paint.setFixedSize(592,552)
        self.lbl = QLabel(u'注：\n\r右图轴的每一格代表10\n\r个采样点，最大512个\n\r采样点，采样频率Fs=\n\r10KHz,纵轴代表电平幅\n\r度，满幅度为5V。')
        self.left_qvbox.addWidget(self.lbl)
        self.qhbox.addLayout(self.left_qvbox)
        self.qhbox.addWidget(self.paint)

    def fft_handle(self, state):
        global channel
        global pyinnerpts
        global fft_data
        global fft_state
        if state == Qt.Checked:
            fft_state = 1
            if channel == 14:
                self.paint.setPoints(fft_data)
            else:
                if channel < 10:
                    msg = '0'+str(channel)+':'+str(fft_state)
                else:
                    msg = str(channel)+':'+str(fft_state)
                s.send(msg.encode('utf-8')) 
        else:
            fft_state = 0
            if channel == 14:
                self.paint.setPoints(pyinnerpts)
                msg = str(channel)+':'+str(fft_state)
                s.send(msg.encode('utf-8')) 
            
    def check_signal(self, sig, state):
        global pyinnerpts
        global channel
        global fft_state
        if state == True:
            if sig < 10:
                msg = '0' + str(sig)+':'+str(fft_state)
            else:
                msg = str(sig)+':'+str(fft_state)
            channel = sig
            if sig == 14:
                self.paint.setPoints(pyinnerpts)
            else:
                s.send(msg.encode('utf-8'))      #style = Qt.PenStyle("Solid",Qt.UserRole)
        #cap = Qt.PenCapStyle('Square', Qt.UserRole)
        #join = Qt.PenJoinStyle('Round',Qt.UserRole)
        #self.paint.se.setPen(QPen(Qt.blue, width, style, cap, join))
        #if sig == 0 and state == Qt.Checked:
           # try:
         #  s.send(bytes('channel:'+str(sig), 'utf-8'))
           # except:
            #    self.exit()
                #y1 = (math.sin(math.pi*2*i/1000)+1)*500
               # x.append(i)
                #y.append(y1)
               # self.paint.setPoints(x, y)
        #elif sig == 1 and state == Qt.Checked:
          # try:
         # s.send(bytes('channel:'+str(sig), 'utf-8'))
          # except:
          #     self.exit()
            #for i in range(0,500):
             #   x.append(i)
             #   y.append(i)
            #self.paint.setPoints(x, y)
            #self.paint.painter.end()

class PaintArea(QWidget):
    
    def __init__(self, parent=None):
        super(PaintArea, self).__init__(parent)
        self.pointxy = []
        self.setBackgroundRole(QPalette.Base)
        self.setAutoFillBackground(True)

    def setPoints(self, pxy):
        self.pointxy = pxy
        self.update()
            
    def paintEvent(self, event):
        self.originx = 20
        self.originy = self.geometry().height()-20-9
        self.painter = QPainter()
        
        self.painter.begin(self)
        #绘制坐标
        self.painter.setPen(QPen(Qt.black, 3, Qt.SolidLine))
        self.painter.drawLine(self.originx, self.originy, self.originx, self.originy - 512)
        self.painter.drawLine(self.originx, self.originy - 512, self.originx - 4, self.originy - 512 + 7)
        self.painter.drawLine(self.originx, self.originy - 512, self.originx + 4, self.originy - 512 + 7)
        for i in range(1, 26):
            self.painter.drawLine(self.originx, self.originy - i*20, self.originx+5, self.originy - i * 20)
        self.painter.drawLine(self.originx + 512, self.originy, self.originx + 512 - 7, self.originy + 4)
        self.painter.drawLine(self.originx + 512, self.originy, self.originx + 512 - 7, self.originy - 4)
        self.painter.drawLine(self.originx, self.originy, self.originx + 512, self.originy)
        for i in range(1, 26):
            self.painter.drawLine(self.originx+i*20, self.originy - 5, self.originx+i*20, self.originy)
        #绘制坐标标注
        self.painter.setPen(QPen(Qt.black, 1, Qt.SolidLine))
        self.painter.setFont(QFont('Decorative', 18))
        self.origin = QPoint(0, 532)
        self.painter.drawText(self.origin, '0')
        self.painter.setPen(QPen(Qt.blue, 1, Qt.SolidLine))
        if channel == 14:
            for i in range(0, int((len(self.pointxy)/2)-1)):
                self.painter.drawLine(self.pointxy[2*i]+self.originx, self.originy-self.pointxy[2*i+1], self.pointxy[2*i+2]+self.originx, self.originy-self.pointxy[2*i+3])
        else:
            for i in range(0, int((len(self.pointxy)/2)-1)):
                self.painter.drawLine(self.pointxy[2*i]*2+self.originx, self.originy-self.pointxy[2*i+1]/2, self.pointxy[2*i+2]*2+self.originx, self.originy-self.pointxy[2*i+3]/2)
            
        self.painter.end()
       
    def sizeHint(self):
        return QSize(400, 200)
    
    def minimumSizeHint(self):
        return QSize(100, 100)
if __name__ == '__main__':
    global fft_state
    fft_state = 0
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    qapp =QApplication(sys.argv)
    m = mainW()
    m.show()
    sys.exit(qapp.exec())
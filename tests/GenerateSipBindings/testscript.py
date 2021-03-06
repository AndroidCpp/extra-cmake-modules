
import sys

from PyQt5 import QtCore

sys.path.append(sys.argv[1])

import PyTest.CppLib

mo = PyTest.CppLib.MyObject()

assert(mo.addThree(39) == 42)

assert(mo.addThree([38, 39, 40]) == [41, 42, 43])

assert(mo.addThree("SomeString") == "DefaultSomeStringThree")

assert(mo.findNeedle(["One", "Two", "Three"], "Two") == 1)
assert(mo.findNeedle(["One", "Two", "Three"], "Four") == -1)
assert(mo.findNeedle(["One", "Two", "Three"], "Th") == 2)
assert(mo.findNeedle(["One", "Two", "Three"], "Th", QtCore.Qt.MatchExactly) == -1)

assert(mo.const_parameters(30) == 15)
assert(mo.const_parameters(30, mo) == 10)

assert(mo.qtEnumTest(QtCore.Qt.MatchContains | QtCore.Qt.MatchStartsWith) == 3)
assert(mo.localEnumTest(PyTest.CppLib.MyObject.Val2) == 2)

class Reactor(QtCore.QObject):
    def __init__(self, obj):
        QtCore.QObject.__init__(self)
        self.gotPrivateSlotCalledSignal = False
        self.gotProtectedSlotCalledSignal = False
        self.gotPublicSlotCalledSignal = False

        obj.privateSlotCalled.connect(self.react_to_privateSlotCalled)
        obj.protectedSlotCalled.connect(self.react_to_protectedSlotCalled)
        obj.publicSlotCalled.connect(self.react_to_publicSlotCalled)

    def react_to_privateSlotCalled(self):
        self.gotPrivateSlotCalledSignal = True

    def react_to_protectedSlotCalled(self):
        self.gotProtectedSlotCalledSignal = True

    def react_to_publicSlotCalled(self):
        self.gotPublicSlotCalledSignal = True

class Emitter(QtCore.QObject):
    privateTrigger = QtCore.pyqtSignal()
    protectedTrigger = QtCore.pyqtSignal()
    publicTrigger = QtCore.pyqtSignal()

    def __init__(self, obj):
        QtCore.QObject.__init__(self)
        self.privateTrigger.connect(obj.privateSlot1)
        self.protectedTrigger.connect(obj.protectedSlot1)
        self.publicTrigger.connect(obj.publicSlot1)

    def emitSignalForPublic(self):
        self.publicTrigger.emit()

    def emitSignalForPrivate(self):
        self.privateTrigger.emit()

    def emitSignalForProtected(self):
        self.protectedTrigger.emit()

e = Emitter(mo)

r = Reactor(mo)

assert(not r.gotPrivateSlotCalledSignal)
assert(not r.gotProtectedSlotCalledSignal)
assert(not r.gotPublicSlotCalledSignal)

e.emitSignalForPrivate()

assert(r.gotPrivateSlotCalledSignal)

e.emitSignalForProtected()

assert(r.gotProtectedSlotCalledSignal)

e.emitSignalForPublic()

assert(r.gotPublicSlotCalledSignal)

#!/usr/bin/env python

import vtk

renderer = vtk.vtkRenderer()
renWin = vtk.vtkRenderWindow()
renWin.AddRenderer(renderer)
interactor = vtk.vtkRenderWindowInteractor()
interactor.SetRenderWindow(renWin)

sphere = vtk.vtkSphereSource()
sphere.SetRadius(20)
res = 5
sphere.SetThetaResolution(res)
sphere.SetPhiResolution(res)
sphere.SetCenter(0,0,0)
polyData = sphere.GetOutput()
polyData.BuildCells()
mapper = vtk.vtkPolyDataMapper()
mapper.SetInput(polyData)

actor = vtk.vtkActor()
actor.SetMapper(mapper) #actor.GetProperty().SetOpacity(0.5)

renderer.AddActor(actor)

def mark(x,y,z):
    sphere = vtk.vtkSphereSource()
    sphere.SetRadius(1)
    res = 20
    sphere.SetThetaResolution(res)
    sphere.SetPhiResolution(res)
    sphere.SetCenter(x,y,z)
    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInput(sphere.GetOutput())

    marker = vtk.vtkActor()
    marker.SetMapper(mapper)
    renderer.AddActor(marker)
    marker.GetProperty().SetColor( (1,0,0) )
    interactor.Render()

def pick_cell(renwinInteractor, event):
    x, y = renwinInteractor.GetEventPosition()

    picker = vtk.vtkCellPicker()
    picker.PickFromListOn()
    picker.AddPickList(actor)
    picker.SetTolerance(0.01)
    picker.Pick(x, y, 0, renderer)
    cellId = picker.GetCellId()
    if cellId==-1:
        print 'swing and a miss'
        return

    polyData.DeleteCell(cellId)
    print 'deleted cell', cellId
    mapper.Update()

interactor.AddObserver('LeftButtonPressEvent', pick_cell)

interactor.Initialize() interactor.Start() 

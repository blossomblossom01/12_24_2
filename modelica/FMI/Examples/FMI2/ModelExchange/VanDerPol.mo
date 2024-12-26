within FMI.Examples.FMI2.ModelExchange;

model VanDerPol
  "This model implements the van der Pol oscillator"

  import FMI.FMI2.Interfaces.*;
  import FMI.FMI2.Functions.*;

  parameter Modelica.Units.SI.Time startTime = 0.0 annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Modelica.Units.SI.Time stopTime = Modelica.Constants.inf annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Real tolerance = 0.0 annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Boolean visible = false annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Boolean loggingOn = false annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Boolean logToFile = false annotation(Dialog(tab="FMI", group="Parameters"));

  parameter String logFile = getInstanceName() + ".txt" annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Boolean logFMICalls = false annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Real 'mu' = 1;

  RealOutput 'x0' annotation (Placement(transformation(extent={ { 600, 23.33333333333333 }, { 620, 43.33333333333333 } }), iconTransformation(extent={ { 600, 23.33333333333333 }, { 620, 43.33333333333333 } })));

  RealOutput 'x1' annotation (Placement(transformation(extent={ { 600, -43.33333333333334 }, { 620, -23.333333333333343 } }), iconTransformation(extent={ { 600, -43.33333333333334 }, { 620, -23.333333333333343 } })));

protected

  FMI.Internal.ModelicaFunctions callbacks = FMI.Internal.ModelicaFunctions();

  FMI.Internal.ExternalFMU instance = FMI.Internal.ExternalFMU(
    callbacks,
    Modelica.Utilities.Files.loadResource("modelica://FMI/Resources/FMUs/0afb323"),
    1,
    "VanDerPol",
    getInstanceName(),
    0,
    "{BD403596-3166-4232-ABC2-132BDF73E644}",
    visible,
    loggingOn,
    logFMICalls,
    logToFile,
    logFile);

  final constant Integer nx = 2;
  final constant Integer nz = 0;

  final constant Integer realInputVRs[0] = fill(0, 0);
  final constant Integer integerInputVRs[0] = fill(0, 0);
  final constant Integer booleanInputVRs[0] = fill(0, 0);

  parameter Real instanceStartTime(fixed=false);

  Real x[nx];
  Real z[nz];
  Real instanceTime;
  Boolean z_positive[nz];
  Boolean inputEvent;
  Boolean valuesOfContinuousStatesChanged;
  Real nextEventTime;

  impure function setTimeAndStates
    input FMI.Internal.ExternalFMU instance;
    input Real t;
    input Real x[:];
    output Real instanceTime;
  algorithm
    FMI2SetTime(instance, t);
    FMI2SetContinuousStates(instance, x, size(x, 1));
    instanceTime := t;
  end setTimeAndStates;

  impure function getDerivatives
    input FMI.Internal.ExternalFMU instance;
    input Real instanceTime;
    output Real dx[nx];
  algorithm
    dx := FMI2GetDerivatives(instance, size(dx, 1));
  end getDerivatives;

  impure function getEventIndicators
    input FMI.Internal.ExternalFMU instance;
    input Real instanceTime;
    input Real realInputs[:];
    input Integer integerInputs[:];
    input Boolean booleanInputs[:];
    output Real z[nz];
  algorithm
    FMI2SetReal(instance, realInputVRs, size(realInputs, 1), realInputs);
    // FMI2SetInteger(instance, integerInputVRs, size(integerInputs, 1), integerInputs);
    // FMI2SetBoolean(instance, booleanInputVRs, size(booleanInputs, 1), booleanInputs);
    z := FMI2GetEventIndicators(instance, size(z, 1));
  end getEventIndicators;

  impure function updateDiscreteStates
    input FMI.Internal.ExternalFMU instance;
    output Boolean valuesOfContinuousStatesChanged;
    output Real nextEventTime;
  algorithm
    FMI2EnterEventMode(instance);
    (valuesOfContinuousStatesChanged, nextEventTime) := FMI2NewDiscreteStates(instance);
    FMI2EnterContinuousTimeMode(instance);
  end updateDiscreteStates;

  impure function setInputs
    input FMI.Internal.ExternalFMU instance;
    input Integer[:] integerInputs;
    input Boolean[:] booleanInputs;
    output Boolean inputEvent;
  algorithm
    FMI2SetInteger(instance, integerInputVRs, size(integerInputs, 1), integerInputs);
    FMI2SetBoolean(instance, booleanInputVRs, size(booleanInputs, 1), booleanInputs);
    inputEvent :=true;
  end setInputs;

initial algorithm

  FMI2SetupExperiment(instance, tolerance > 0.0, tolerance, startTime, stopTime < Modelica.Constants.inf, stopTime);

  FMI2SetReal(instance, {5}, 1, {'mu'});

  FMI2EnterInitializationMode(instance);


  FMI2ExitInitializationMode(instance);

  (valuesOfContinuousStatesChanged, nextEventTime) := FMI2NewDiscreteStates(instance);
  FMI2EnterContinuousTimeMode(instance);
  x := FMI2GetContinuousStates(instance, nx);
  instanceStartTime := time;

equation

  instanceTime = setTimeAndStates(instance, time, x);

  der(x) = getDerivatives(instance, instanceTime);

  z = getEventIndicators(instance, instanceTime, fill(0.0, 0), fill(0, 0), fill(false, 0));

  for i in 1:size(z, 1) loop
    z_positive[i] = z[i] > 0;
  end for;

  inputEvent = setInputs(instance, fill(0, 0), fill(false, 0));

  when cat(1, {time >= pre(nextEventTime)}, change(z_positive), {inputEvent}) then
    (valuesOfContinuousStatesChanged, nextEventTime) = updateDiscreteStates(instance);
  end when;

  when valuesOfContinuousStatesChanged then
    reinit(x, FMI2GetContinuousStates(instance, nx));
  end when;

  if initial() then
    'x0' = FMI2GetRealScalar(instance, 1, instanceStartTime);
    'x1' = FMI2GetRealScalar(instance, 3, instanceStartTime);
  else
    'x0' = FMI2GetRealScalar(instance, 1, instanceTime);
    'x1' = FMI2GetRealScalar(instance, 3, instanceTime);
  end if;

algorithm
  if initial() then
    FMI2SetTime(instance, instanceStartTime);
  else
    FMI2SetTime(instance, instanceTime);
  end if;

  annotation (
    Icon(coordinateSystem(
      preserveAspectRatio=false,
      extent={{-600,-100}, {600,100}}),
      graphics={
        Text(extent={{-600,110}, {600,150}}, lineColor={0,0,255}, textString="%name"),
        Rectangle(extent={{-600,-100},{600,100}}, lineColor={95,95,95}, fillColor={255,255,255}, fillPattern=FillPattern.Solid)
      }
    ),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-600,-100}, {600,100}})),
    experiment(StopTime=20.0)
  );
end VanDerPol;
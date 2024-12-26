within FMI.Examples.FMI2.CoSimulation;

model BouncingBall
  "This model calculates the trajectory, over time, of a ball dropped from a height of 1 m."

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

  parameter Modelica.Units.SI.Time communicationStepSize = 0.01 annotation(Dialog(tab="FMI", group="Parameters"));

  parameter Real 'g' = -9.81 "Gravity acting on the ball";

  parameter Real 'e' = 0.7 "Coefficient of restitution";

  RealOutput 'h' annotation (Placement(transformation(extent={ { 600, 23.33333333333333 }, { 620, 43.33333333333333 } }), iconTransformation(extent={ { 600, 23.33333333333333 }, { 620, 43.33333333333333 } })));

  RealOutput 'v' annotation (Placement(transformation(extent={ { 600, -43.33333333333334 }, { 620, -23.333333333333343 } }), iconTransformation(extent={ { 600, -43.33333333333334 }, { 620, -23.333333333333343 } })));

protected

  FMI.Internal.ModelicaFunctions callbacks = FMI.Internal.ModelicaFunctions();

  FMI.Internal.ExternalFMU instance = FMI.Internal.ExternalFMU(
    callbacks,
    Modelica.Utilities.Files.loadResource("modelica://FMI/Resources/FMUs/c173def"),
    1,
    "BouncingBall",
    getInstanceName(),
    1,
    "{1AE5E10D-9521-4DE3-80B9-D0EAAA7D5AF1}",
    visible,
    loggingOn,
    logFMICalls,
    logToFile,
    logFile);
  Boolean initialized;

initial algorithm

  FMI2SetupExperiment(instance, tolerance > 0.0, tolerance, startTime, stopTime < Modelica.Constants.inf, stopTime);

  FMI2SetReal(instance, {5}, 1, {'g'});
  FMI2SetReal(instance, {6}, 1, {'e'});

  FMI2EnterInitializationMode(instance);


algorithm

  when {initial(), sample(startTime, communicationStepSize)} then


    if time >= communicationStepSize + startTime then
      if not initialized then
        FMI2ExitInitializationMode(instance);
        initialized := true;
      end if;
      FMI2DoStep(instance, time, communicationStepSize, true);
    end if;

    'h' := FMI2GetRealScalar(instance, 1);
    'v' := FMI2GetRealScalar(instance, 3);

  end when;

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
    experiment(StopTime=3.0)
  );
end BouncingBall;
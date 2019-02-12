{ A Activer en debugging }
{$DEFINE Debugging}

{$IFDEF FinalVersion}
  {$UNDEF Debugging}
{$ENDIF}

{ Versions de Delphi }
{$IFDEF VER180}
  {$DEFINE DELPHI_10}
  {$DEFINE DELPHI_9}
  {$DEFINE DELPHI_8}
  {$DEFINE DELPHI_7}
  {$DEFINE DELPHI_6}
  {$DEFINE DELPHI_5}
{$ENDIF}

{$IFDEF VER170}
  {$DEFINE DELPHI_9}
  {$DEFINE DELPHI_8}
  {$DEFINE DELPHI_7}
  {$DEFINE DELPHI_6}
  {$DEFINE DELPHI_5}
{$ENDIF}

{$IFDEF VER160}
  {$DEFINE DELPHI_8}
  {$DEFINE DELPHI_7}
  {$DEFINE DELPHI_6}
  {$DEFINE DELPHI_5}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE DELPHI_7}
  {$DEFINE DELPHI_6}
  {$DEFINE DELPHI_5}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE DELPHI_6}
  {$DEFINE DELPHI_5}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE DELPHI_5}
{$ENDIF}

{ Le XPManifest n'est utilisable que depuis Delphi 7 }
{$IFDEF DELPHI_7}
  {$DEFINE EnableXPMan}
{$ENDIF}

{ Spécificités de Delphi 2005 et sup: les régions et la directive "inline" }
{$IFDEF DELPHI_9}
  {$DEFINE EnableRGN}
  {$DEFINE EnableInline}
{$ENDIF}

(*
  { Prêts pour le copier/coller }

  {$IFDEF EnableXPMan}, XPMan{$ENDIF}

  {$IFDEF EnableRGN}{$REGION ''}{$ENDIF}
  {$IFDEF EnableRGN}{$ENDREGION}{$ENDIF}

  {$IFDEF EnableInline}inline;{$ENDIF}
  {$IFDEF EnableInline}{$INLINE ON}{$ENDIF}
*)

{ Alignement par défaut des types structurés non packed }
{$ALIGN 8}

{ Type de chaine string => chaîne longue }
{$LONGSTRINGS ON}

{ Pas de constantes typees affectables }
{$WRITEABLECONST OFF}

{ Erreurs lors des operations I/O }
{$IOCHECKS ON}

{ Désactive l'évaluation booléenne complète }
{$BOOLEVAL OFF}

{ Optimisation activée sauf si debuging poussé }
{$IFDEF HighDebugging}
  {$OPTIMIZATION OFF}
{$ELSE}
  {$OPTIMIZATION ON}
{$ENDIF}

{ Pas de gestion pour les pentiums où l'opération FDIV est mauvaise }
{$SAFEDIVIDE OFF}

{ Gestion des limites, infos de debug, débordement: activées par défaut
 mais à enlever après le débugging. Pareil pour les assertions }
{$IFDEF Debugging}
  {$ASSERTIONS ON}
  {$DEBUGINFO ON}
  {$OVERFLOWCHECKS ON}
  {$RANGECHECKS ON}
{$ELSE}
  {$ASSERTIONS OFF}
  {$DEBUGINFO OFF}
  {$OVERFLOWCHECKS OFF}
  {$RANGECHECKS OFF}
{$ENDIF}


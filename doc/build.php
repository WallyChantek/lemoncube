<?php

error_log("Building documentation");

$templatePath = "template.html";
$sourceDir = "data/";
$outputDir = "pages/";
$tocPath = "data/table-of-contents.json";

// Load HTML template
$htmlTemplate = file_get_contents($templatePath);
if(!$htmlTemplate) {
  error_log("Could not load HTML template");
}

// Load Table of Contents data
$toc = file_get_contents($tocPath);
if(!$toc) {
  error_log("Could not load Table of Contents data");
}
$toc = json_decode($toc, true);
if(!$toc) {
  error_log("Could not parse Table of Contents JSON data");
}

// Create output directory if it doesn't exist
if(!file_exists($outputDir))
  mkdir($outputDir, 0777, true);

$modules = glob("$sourceDir*.json");
$ignore = array(
  "table-of-contents.json"
);
foreach($modules as $module)
{
  $module = pathinfo($module);
  if(in_array($module["basename"], $ignore))
    continue;

  error_log("Building page: " . $outputDir . $module["filename"] . ".html");

  buildPage(
    $sourceDir . $module["basename"],
    $outputDir . $module["filename"] . ".html",
    $htmlTemplate,
    $toc
  );
}

function buildPage($srcPath, $destPath, $html, $toc)
{
  $data = file_get_contents($srcPath);
  if(!$data) {
    error_log("Could not load JSON data");
  }
  $data = json_decode($data, true);
  if(!$data) {
    error_log("Could not parse JSON data");
    exit();
  }

  // Table of Contents
  $h = "";
  foreach($toc as $tSection => $tModules)
  {
    $h .= "<li>$tSection" . PHP_EOL;
    $h .= "<ul>" . PHP_EOL;
    foreach($tModules as $moduleName)
    {
      $h .= "<li><a ";
      $h .= ($data["class"] == $moduleName ? "class=\"toc-current\"" : "");
      $h .= "href=\"" . str_replace(" ", "-", strtolower($moduleName)) .
        "\">" . $moduleName . "</a></li>" . PHP_EOL;
    }
    $h .= "</ul>" . PHP_EOL;
  }
  $html = str_replace("{tableOfContents}", $h, $html);

  // Name & Overview
  $html = str_replace("{name}", $data["class"], $html);
  $html = str_replace("{abstract}", $data["abstract"], $html);
  $html = str_replace("{information}", $data["information"], $html);

  // Basic Usage
  if(is_array($data["basicUsage"])) {
    $d = $data["basicUsage"];
    $h = "<" . $d[0] . ">" . PHP_EOL;
    for($i = 1; $i < count($d); $i++)
      $h .= "<li>" . $d[$i] . "</li>" . PHP_EOL;
    $h .= "</" . $d[0] . ">";
    $html = str_replace("{basicUsage}", $h, $html);
  }
  else
    $html = str_replace("{basicUsage}", "<p>" . $data["basicUsage"] . "</p>",
      $html);

  // Method Summary
  $h = "";
  foreach($data["methods"] as $mName => $mData) {
    $h .= "<tr>" . PHP_EOL;
    $h .= "<td>" . (isset($mData["returnType"]) ?
      $mData["returnType"] : "void") . "</td>" . PHP_EOL;
    $h .= "<td><a href=\"#" . str_replace(" ", "-",
      strtolower(explode("(", $mName)[0])) . "\">" . $mName . "</a><br/>" .
      $mData["description"] . "</td>" . PHP_EOL;
    $h .= "</tr>";
  }
  $html = str_replace("{methodSummary}", $h, $html);

  // Method Detail
  $h = "";
  $i = 0;
  foreach($data["methods"] as $mName => $mData) {
    $mNameStripped = explode("(", $mName)[0];
    $h .= "<h3 id=\"" . strtolower($mNameStripped) . "\">" . $mNameStripped .
      "</h3>" . PHP_EOL;
    $h .= "<p class=\"code\">" . $mName . "</p>" . PHP_EOL;
    $h .= "<p>" . $mData["description"] . "</p>" . PHP_EOL;
    if(isset($mData["information"]))
      $h .= "<p>" . $mData["information"] . "</p>" . PHP_EOL;

    // Parameters
    if(isset($mData["parameters"]))
    {
      $h .= "<table>" . PHP_EOL;
      $h .= "<tr><th colspan=\"2\">Parameters</th></tr>" . PHP_EOL;
      foreach($mData["parameters"] as $pName => $pDesc)
      {
        $h .= "<tr>" . PHP_EOL;
        $h .= "<td>$pName</td>" . PHP_EOL;
        $h .= "<td>$pDesc</td>" . PHP_EOL;
        $h .= "</tr>" . PHP_EOL;
      }
      $h .= "</table>" . PHP_EOL;
    }

    // Returns
    if(isset($mData["returnType"]))
    {
      $h .= "<table>" . PHP_EOL;
      $h .= "<tr><th colspan=\"2\">Returns</th></tr>" . PHP_EOL;
      $h .= "<tr>" . PHP_EOL;
      $h .= "<td>" . $mData["returnType"] . "</td>" . PHP_EOL;
      $h .= "<td>" . $mData["returnValue"] . "</td>" . PHP_EOL;
      $h .= "</tr>" . PHP_EOL;
      $h .= "</table>" . PHP_EOL;
    }

    $i++;

    if($i < count($data["methods"]))
      $h .= "<br/>" . PHP_EOL;
  }
  $html = str_replace("{methodDetail}", $h, $html);


  // Output HTML file
  file_put_contents($destPath, $html);
}

?>
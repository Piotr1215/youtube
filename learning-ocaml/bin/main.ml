open Cmdliner

(* The actual logic *)
let run input_file output_file verbose =
  if verbose then
    Printf.printf "Reading from: %s\n" input_file;
  Printf.printf "Would compile %s -> %s\n" input_file output_file

(* CLI argument definitions - these give you autocompletion *)
let input_file =
  let doc = "Input file containing alert definitions" in
  Arg.(required & pos 0 (some file) None & info [] ~docv:"INPUT" ~doc)

let output_file =
  let doc = "Output YAML file for PrometheusRule" in
  Arg.(value & opt string "alerts.yaml" & info ["o"; "output"] ~docv:"FILE" ~doc)

let verbose =
  let doc = "Enable verbose output" in
  Arg.(value & flag & info ["v"; "verbose"] ~doc)

(* Combine args into the command *)
let cmd =
  let doc = "Compile PromQL DSL to Prometheus alerting rules" in
  let info = Cmd.info "promql" ~version:"0.1.0" ~doc in
  Cmd.v info Term.(const run $ input_file $ output_file $ verbose)

(* Entry point *)
let () = exit (Cmd.eval cmd)

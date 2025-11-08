# D2 Diagram Examples

This directory contains example D2 diagrams showcasing different diagram styles and use cases for DevOps/Kubernetes content.

## What is D2?

D2 is a modern diagram scripting language that turns text to diagrams. It's designed to be:
- **Simple**: Clean, intuitive syntax
- **Powerful**: Supports complex layouts and styling
- **Fast**: Quick rendering to multiple formats
- **Flexible**: Multiple output formats (SVG, PNG, ASCII)

## Installation

```bash
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

## Examples

### 1. kubernetes-architecture.d2
**Complex System Architecture**

A comprehensive Kubernetes application stack showing:
- Multi-tier architecture (ingress, app, data layers)
- Service mesh integration (Istio/Envoy)
- Observability stack (Prometheus, Grafana, Loki)
- Data layer components (PostgreSQL, Redis, S3)

**Use for**: System design presentations, architecture reviews

### 2. workflow.d2
**CI/CD Pipeline Flowchart**

A detailed CI/CD workflow diagram featuring:
- Development to production flow
- Build, test, and deployment stages
- Conditional paths (approval gates, error handling)
- Integration with multiple environments

**Use for**: DevOps process documentation, pipeline tutorials

### 3. comparison.d2
**Before/After Comparison**

A side-by-side comparison showing:
- Monolithic vs microservices architecture
- Visual contrast with color coding
- Metrics table for quantitative comparison
- Migration journey visualization

**Use for**: Modernization talks, architecture evolution stories

## Usage with Justfile

### Render to SVG
```bash
just d2 kubernetes-architecture
```

### Render with sketch style
```bash
just d2-sketch workflow
```

### Render to ASCII (for terminal/slides)
```bash
just d2-ascii comparison
```

## Tips for Creating D2 Diagrams

1. **Start simple**: Begin with basic shapes and connections
2. **Use containers**: Group related components with nested structures
3. **Apply styling**: Use `style.fill` and `style.stroke` for visual hierarchy
4. **Add direction**: Use `direction: right` or `direction: down` for layout control
5. **Include notes**: Add context with `.note` attributes
6. **Use shapes**: Leverage built-in shapes (person, cloud, cylinder, hexagon, etc.)

## Reference

- [D2 Official Docs](https://d2lang.com/)
- [D2 Playground](https://play.d2lang.com/)
- [Shape Gallery](https://d2lang.com/tour/shapes)
- [Styling Guide](https://d2lang.com/tour/style)

## Migration from Other Tools

To identify existing diagrams that could be migrated to D2:

```bash
just migrate-to-d2 /path/to/folder
```

This will scan for `.dot` (GraphViz) and `.puml` (PlantUML) files.

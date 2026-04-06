# Lab 05 - Dependencies and the Terraform Graph

## Learning Objective

Understand implicit and explicit dependencies in Terraform and visualize the dependency graph that Terraform automatically computes from your configuration.

## Concept

When you connect resources with references (like putting a subnet inside a VPC), Terraform automatically knows the VPC must be created first. This is an **implicit dependency**. You never write "wait for VPC" -- Terraform builds a **directed acyclic graph (DAG)** and figures it out.

There is no orchestration script. No sleep commands. No "retry until ready." Terraform reads your entire configuration, builds a graph of every resource and its dependencies, and then walks that graph in the correct order -- parallelizing independent resources along the way.

In this lab you will build a realistic multi-resource ShopSmart infrastructure stack and see this in action.

---

## Exercise 1: Read the Code and Draw the Dependency Tree

Open `main.tf` and read through each resource block. Pay attention to every place one resource **references** another resource's attribute (for example, `aws_vpc.main.id`).

On paper or a whiteboard, draw the dependency tree:
- Which resource has zero dependencies? (That is the root.)
- Which resources depend on the VPC?
- Which resources depend on the subnet?
- What is the "longest chain" from root to leaf?

Keep your drawing -- you will compare it to the real graph in Exercise 3.

---

## Exercise 2: Init and Plan

```bash
terraform init
terraform plan
```

Questions to answer:
1. How many resources will Terraform create?
2. Does the plan output hint at the creation order?
3. Are there any resources that could be created in parallel (no dependency between them)?

---

## Exercise 3: Generate the Dependency Graph

Terraform can export its dependency graph in DOT format. If you have [Graphviz](https://graphviz.org/) installed, you can render it as an image:

```bash
terraform graph | dot -Tpng > graph.png
```

Open `graph.png` in an image viewer and compare it to the tree you drew by hand in Exercise 1.

- Did you get it right?
- Are there edges (arrows) you did not expect?
- Notice how the `provider` node is a dependency for every resource.

> **Tip:** If you do not have Graphviz installed, you can paste the output of `terraform graph` into an online viewer such as https://dreampuf.github.io/GraphvizOnline/.

---

## Exercise 4: Apply and Watch the Order

```bash
terraform apply
```

Watch the output carefully as Terraform creates each resource. You will see:
1. The VPC is created first (it has no dependencies).
2. The subnet, internet gateway, and S3 bucket can be created in parallel (they only depend on the VPC or nothing).
3. The security group is created after the VPC.
4. The route table is created after the VPC and internet gateway.
5. The EC2 instance is created last -- it depends on the subnet and the security group.

Terraform did all of this **without a single wait command**. It figured out the order from your references alone.

---

## Exercise 5 (Experiment): Explicit Dependencies with `depends_on`

Sometimes you need a dependency that is not expressed through a reference. For example, suppose your EC2 instance writes logs and you want a CloudWatch Log Group to exist before the instance starts -- but there is no attribute reference connecting them.

Add this to `main.tf`:

```hcl
resource "aws_cloudwatch_log_group" "shopsmart_logs" {
  name              = "/shopsmart/application"
  retention_in_days = 7

  # Explicit dependency: no reference to the instance, but we want
  # Terraform to create the instance first.
  depends_on = [aws_instance.web]

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}
```

Now regenerate the graph:

```bash
terraform graph | dot -Tpng > graph-with-depends-on.png
```

Open the new image. You will see a new edge from `aws_instance.web` to `aws_cloudwatch_log_group.shopsmart_logs` -- an edge that exists purely because of `depends_on`, not because of any attribute reference.

---

## Exercise 6: Destruction Order

Terraform respects the dependency graph in reverse when destroying resources.

**Test 1:** Remove just the EC2 instance (`aws_instance.web`) from `main.tf`. Run:

```bash
terraform plan
```

Terraform will propose destroying only the instance (a "leaf" node with no dependents).

**Test 2:** Undo that change and instead try removing the VPC (`aws_vpc.main`). Run:

```bash
terraform plan
```

Terraform knows it must destroy the instance, the subnet, the security group, the internet gateway, and the route table BEFORE it can destroy the VPC. The graph enforces this automatically.

> **Important:** Run `terraform destroy` when you are finished to clean up all resources and avoid charges.

---

## Key Takeaway

Terraform is not running your code top-to-bottom like a script. It is building a graph and executing it in the optimal order. Every reference between resources becomes an edge in that graph. The graph guarantees correctness (dependencies are respected) and performance (independent resources are created in parallel).

This is one of the most powerful ideas in infrastructure as code.

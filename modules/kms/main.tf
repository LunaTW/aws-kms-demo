resource "aws_iam_policy" "kms" {
  name        = "kms-${var.key_name}-policy"
  path        = "/"
  description = ""
  policy      = "${data.aws_iam_policy_document.kms_key_policy_document.json}"
}

data "aws_iam_policy_document" "kms_key_policy_document" {
  statement {
    sid = "AllowUseOfTheKey"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["${aws_kms_key.key.arn}"]
  }
}

resource "aws_kms_key" "key" {
  policy = "${data.template_file.kms_policy.rendered}"
}

data "template_file" "kms_policy" {
  template = "${file("${path.module}/kms_policy.json.tpl")}"

  vars {
    account_id = "${var.account_id}"
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.key_name}"
  target_key_id = "${aws_kms_key.key.key_id}"
}

output "iam_policy_arn" {
  value = "${aws_iam_policy.kms.arn}"
}

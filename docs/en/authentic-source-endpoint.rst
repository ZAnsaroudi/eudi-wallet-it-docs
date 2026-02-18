.. include:: ../common/common_definitions.rst


.. role:: raw-html(raw)
  :format: html

Authentic Source Endpoints
--------------------------

e-Service PDND Authentic Source Catalog
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Public Authentic Sources MUST provide the following e-Service through PDND to provide the Credential Issuer with User's attributes required to the issuance of a Digital Credential.

.. only:: html

  .. note::
    A complete OpenAPI Specification is available :raw-html:`<a href="OAS3-PDND-AS.html" target="_blank">here</a>`.

.. only:: latex

  .. note::
    A complete OpenAPI Specification is available :ref:`e-service-pdnd-template:Authentic Source PDND OpenAPI Specification`.

Get Attribute Claims
""""""""""""""""""""

.. _authentic-source-endpoint-get-attribute-claims:
.. list-table::
  :class: longtable
  :widths: 20 80
  :stub-columns: 1

  * - **Description**
    - This e-Service provides the Credential Issuer with all attribute claims necessary for the issuance of a Digital Credential.
  * - **Provider**
    - Authentic Source
  * - **Consumer**
    - Credential Issuer

.. note::
  The Authentic Source and the Credential Issuer MUST implement the necessary logic to keep track of the requests and responses exchanged via this e-Service, in order to be able to correlate them with the related issuance of a Digital Credential. In particular,
    - both MUST save the ``jti`` value in the Agid-JWT-Signature payload of the request to manage Signals related to the deffered issuance of a Digital Credential (see :ref:`signal-hub-endpoint:Signals Processing`);
    - the Authentic Source MUST record the datetime value provided within the ``last_updated`` parameter, which indicates the last time the User's attributes were updated in the Authentic Source's database;
    - the Credential Issuer MUST read the ``last_updated`` value received in the response to be able to check if the User's attributes have changed since the last issuance of a Digital Credential.

Credential Lifecycle States Mapping
"""""""""""""""""""""""""""""""""""

To ensure consistency between the "Electronic Attestation Lifecycle" documented in :ref:`credential-revocation:Digital Credential Lifecycle` and the OpenAPI status Enum, the following mapping MUST be applied for the ``status`` field in the ``attributeClaims``:

.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - **Lifecycle State (Ch. 11.3)**
     - **OpenAPI status enum**
     - **Description and Logic**
   * - **Issued** / **Valid**
     - ``VALID``
     - The dataset is administratively active and within its validity period.
   * - **Expired**
     - ``VALID``
     - The technical credential (mDL/SD-JWT) has expired, but the underlying dataset remains administratively valid. This allows for credential re-issuance.
   * - **Suspended**
     - ``SUSPENDED``
     - The attestation is temporarily invalid.
   * - **Revoked**
     - ``INVALID``
     - The attestation has been actively revoked or terminated at the source.

**Operational Guidance:**

* **Technical vs Administrative Validity**: Credentials distinguish between a **technical validity** set by the Issuer (claims ``iat`` and ``exp``) and an **administrative validity** determined by the Authentic Source (claims ``issuance_date`` and ``expiry_date``).
* **Expiry Hierarchy**: The technical expiry (``exp``) MUST NOT be later than the administrative expiry (``expiry_date``). For example, a driver's license may be administratively valid for 10 years, while the issued mDL credential may have a technical expiry of 1 year.
* **Re-issuance**: If a credential reaches its technical expiry (``exp``) but the dataset is still administratively valid, the OpenAPI status remains ``VALID``, allowing the credential to be re-issued multiple times within the administrative timeframe.
* **Metadata Verification**: The Credential Issuer MUST verify the effective usability by checking both the technical claims and the administrative dates.
* **Irreversibility**: After a transition to ``INVALID``, the Credential cannot return to a ``VALID`` state. A new issuance is required for a new dataset.
* **Signal Processing**: Signals MUST be processed sequentially. If a signal invalidates a Credential, subsequent correction signals for the same object are ignored.

Example of Authentic Source response
"""""""""""""""""""""""""""""""""""""

The endpoint response MUST use the HTTP Content-Type set to ``application/json``. Below is a concrete example with fictitious data to clarify the expected shape and content.

.. literalinclude:: ../../examples/credential-claims-response-example.json
  :language: json
  :caption: Example of the response JSON payload (Get Attribute Claims)

In summary:

- **userClaims**: user identity data (first name, family name, date/place of birth, tax id or personal administrative number). At least one of ``tax_id_code`` and ``personal_administrative_number`` is required when providing user claims.
- **attributeClaims**: array of datasets; each element **MUST** contain ``object_id``, ``status`` (VALID | INVALID | SUSPENDED), ``last_updated`` (ISO 8601 format), plus any dataset-specific attributes (e.g. ``nationality``, ``residence_address``).
- **metadataClaims**: array of metadata per dataset (``object_id`` required; ``issuance_date`` and ``expiry_date`` optional).
- **interval**: required when the request does not include a ``claims`` parameter; indicates the number of seconds to wait before repeating the request (e.g. 864000 = 10 days).

The successful response (HTTP 200) returns a ``CredentialClaimsResponse`` object formatted as a **Payload JSON**.

Signature Verification and Key Management
'''''''''''''''''''''''''''''''''''''''''

As the response token is signed, the Credential Issuer (Consumer) MUST verify the signature to ensure the integrity and authenticity of the data received from the Authentic Source.

The signature verification and key retrieval process MUST strictly follow the standard pattern defined for **PDND e-Services**.
Please refer to the Technical Appendix (Section :ref:`e-service-pdnd:e-Service PDND`) for details on JWT validation and specifications for retrieving the Provider's public key via the Interoperability API.

.. warning::
  Alternative mechanisms for distributing cryptographic material (e.g., public ``.well-known`` endpoints directly exposed by the Authentic Source or *out-of-band* distribution) are not allowed. Trust management MUST remain centralized within the perimeter of the PDND infrastructure as described in the references cited above.
